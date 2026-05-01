(* ocdwm window - window handlers *)
[@@@landmark "auto"]

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

module Tag_set = Ocdwm_core.Tag_set
module Utils = Ocdwm_core.Utils
open Ocdwm_core.Types
open Types

let next_id = Atomic.make 1

let fresh_id () =
  let id = Atomic.get next_id in
  Atomic.incr next_id;
  id

let create
      (wm : window_manager)
      (river_window : [ `V4 ] Rwm.River_window_v1.t)
  =
  let node =
    object
      inherit [_] Rwm.River_node_v1.v4
    end
  in
  {
    obj = river_window;
    node = Rwm.River_window_v1.get_node river_window node;
    state = W_new;
    id = fresh_id ();
    app_id = None;
    title = None;
    identifier = None;
    unreliable_pid = None;
    parent = None;
    decoration_hint = None;
    presentation_hint = None;
    geom = { x = 0l; y = 0l; w = 0l; h = 0l };
    float_geom = None;
    size_hints =
      { min_w = 0l; max_w = 0l; min_h = 0l; max_h = 0l };
    tags =
      begin match wm.focused_output with
      | None -> Tag_set.singleton 1
      | Some o -> o.selected_tags
      end;
    output = wm.focused_output;
    is_fixed = false;
    is_urgent = false;
    is_maximized = false;
    is_hidden = false;
    presentation = P_tiled;
    requests = [];
  }

let state_to_string = function
  | W_active -> "active"
  | W_closing -> "closing"
  | W_new -> "new"

let destroy (w : window) =
  match w.state with
  | W_closing -> begin
      Rwm.River_window_v1.destroy w.obj;
      Wayland.Proxy.delete w.obj;
      Rwm.River_node_v1.destroy w.node
    end
  | _ ->
      Logs.warn (fun m ->
        m "destroy refused: Window is %s not closing."
          (state_to_string w.state))

let set_position
      (wm : window_manager)
      (w : window)
      ~(x : int32)
      ~(y : int32)
  =
  Phase.during_cycle wm ~op:"set_position" (fun () ->
    begin
      w.geom <- { w.geom with x; y };
      Rwm.River_node_v1.set_position w.node ~x ~y
    end)

let river_sync_geom
      (wm : window_manager)
      (w : window)
      (g : int32 rect)
  =
  Phase.during_manage wm ~op:"river_sync_geom" (fun () ->
    begin
      Rwm.River_node_v1.set_position w.node ~x:g.x ~y:g.y;
      Rwm.River_window_v1.propose_dimensions w.obj
        ~width:g.w ~height:g.h
    end)

let set_geom
      (wm : window_manager)
      (w : window)
      (g : int32 rect)
  =
  Phase.during_manage wm ~op:"set_geom" (fun () ->
    begin
      w.geom <- g;
      river_sync_geom wm w g
    end)

let tag_visible (w : window) =
  match w.output with
  | Some o -> Tag_set.intersects w.tags o.selected_tags
  | None -> false

let is_tiled (w : window) = w.presentation = P_tiled

let remember_float (w : window) =
  w.float_geom <- Some w.geom

let tile (w : window) =
  if w.presentation = P_floating then remember_float w;
  w.presentation <- P_tiled

let clamp_dim ~min_v ~max_v v =
  v
  |> (if min_v > 0l then Int32.max min_v else Fun.id)
  |> if max_v > 0l then Int32.min max_v else Fun.id

let clamp (w : window) (g : int rect) =
  let h = w.size_hints in
  Int32.
    {
      x = of_int g.x;
      y = of_int g.y;
      w =
        of_int g.w
        |> clamp_dim ~min_v:h.min_w ~max_v:h.max_w;
      h =
        of_int g.h
        |> clamp_dim ~min_v:h.min_h ~max_v:h.max_h;
    }

let clamp32 (w : window) (g : int32 rect) =
  let h = w.size_hints in
  Int32.
    {
      x = g.x;
      y = g.y;
      w = clamp_dim ~min_v:h.min_w ~max_v:h.max_w g.w;
      h = clamp_dim ~min_v:h.min_h ~max_v:h.max_h g.h;
    }

let restore_or_seed_float (wm : window_manager) (w : window)
  =
  Phase.during_manage wm ~op:"restore_or_seed_float"
    (fun () ->
       begin match w.output with
       | None -> ()
       | Some o -> begin
           let g =
             match w.float_geom with
             | Some g -> g
             | None -> begin
                 let usable =
                   Int32.
                     {
                       x = of_int o.usable.x;
                       y = of_int o.usable.y;
                       w = of_int o.usable.w;
                       h = of_int o.usable.h;
                     }
                 in
                 Int32.
                   {
                     x = div usable.w 4l |> add usable.x;
                     y = div usable.h 4l |> add usable.y;
                     w = div usable.w 2l;
                     h = div usable.h 2l;
                   }
                 |> clamp32 w
               end
           in
           w.float_geom <- Some g;
           set_geom wm w g
         end
       end)

let float (wm : window_manager) (w : window) =
  Phase.during_manage wm ~op:"float" (fun () ->
    begin
      w.presentation <- P_floating;
      restore_or_seed_float wm w
    end)

let toggle_floating
      (wm : window_manager)
      (window : window option)
  =
  Phase.during_manage wm ~op:"toggle_floating" (fun () ->
    begin match window with
    | None -> ()
    | Some (w : window) ->
        begin if w.output <> None then
          match w.presentation with
          | P_tiled -> float wm w
          | P_floating when not w.is_fixed -> tile w
          | P_floating
          | P_fullscreen _ ->
              ()
        end
    end)

let is_fullscreen (w : window) =
  match w.presentation with
  | P_fullscreen _ -> true
  | _ -> false

let fullscreen
      (wm : window_manager)
      (w : window)
      (r : [ `Tiled | `Floating ])
  =
  Phase.during_manage wm ~op:"fullscreen" (fun () ->
    begin match w.output with
    | None -> ()
    | Some o -> begin
        w.presentation <- P_fullscreen { restore = r };
        Rwm.River_window_v1.fullscreen w.obj ~output:o.obj;
        Rwm.River_window_v1.inform_fullscreen w.obj
      end
    end)

let exit_fullscreen
      (wm : window_manager)
      (w : window)
      (p : [ `Tiled | `Floating ])
  =
  Phase.during_manage wm ~op:"exit_fullscreen" (fun () ->
    begin match (w.output, w.presentation) with
    | Some _, P_fullscreen _ -> begin
        Rwm.River_window_v1.exit_fullscreen w.obj;
        Rwm.River_window_v1.inform_not_fullscreen w.obj;
        match p with
        | `Tiled -> tile w
        | `Floating -> float wm w
      end
    | _ -> ()
    end)

let is_rendered (w : window) =
  tag_visible w
  &&
  match w.output with
  | None -> false
  | Some o ->
      not
      @@ List.exists
           (fun w' ->
              w' != w && is_fullscreen w' && tag_visible w')
           o.focus_stack

let sync (wm : window_manager) (w : window) =
  Phase.during_cycle wm ~op:"sync" (fun () ->
    begin
      let should_render = is_rendered w in
      match (should_render, w.is_hidden) with
      | true, true -> begin
          Rwm.River_window_v1.show w.obj;
          w.is_hidden <- false
        end
      | false, false -> begin
          Rwm.River_window_v1.hide w.obj;
          w.is_hidden <- true
        end
      | _, _ -> ()
    end)

let queue_request (w : window) (r : window_request) =
  w.requests <- r :: w.requests

let clear_requests (w : window) = w.requests <- []

let fit_to_output (wm : window_manager) (w : window) =
  Phase.during_cycle wm ~op:"fit_to_output" (fun () ->
    begin match w.output with
    | None -> ()
    | Some o -> begin
        let new_x =
          if w.geom.w > o.geom.w then o.geom.x
          else
            let max_x =
              Int32.(sub o.geom.w w.geom.w |> add o.geom.x)
            in
            Int32.(w.geom.x |> max o.geom.x |> min max_x)
        in
        let new_y =
          if w.geom.h > o.geom.h then o.geom.y
          else
            let max_y =
              Int32.(sub o.geom.h w.geom.h |> add o.geom.y)
            in
            Int32.(w.geom.y |> max o.geom.y |> min max_y)
        in
        if new_x <> w.geom.x || new_y <> w.geom.y then
          set_position wm w ~x:new_x ~y:new_y
      end
    end)

let at_point ~(x : int32) ~(y : int32) =
  List.find_opt (fun (w : window) ->
    tag_visible w && Utils.in_rect ~x ~y ~g:w.geom)
