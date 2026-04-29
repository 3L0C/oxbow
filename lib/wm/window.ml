(* ocdwm window - window handlers *)
[@@@landmark "auto"]

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

module Tag_set = Ocdwm_core.Tag_set
open Ocdwm_core.Types
open Types

let destroy (w : window) =
  Rwm.River_window_v1.destroy w.obj;
  Wayland.Proxy.delete w.obj;
  Rwm.River_node_v1.destroy w.node

let set_position (w : window) ~(x : int32) ~(y : int32) =
  w.geom <- { x; y; w = w.geom.w; h = w.geom.h };
  Rwm.River_node_v1.set_position w.node ~x ~y

let river_sync_geom (w : window) (g : int32 rect) =
  Rwm.River_node_v1.set_position w.node ~x:g.x ~y:g.y;
  Rwm.River_window_v1.propose_dimensions w.obj ~width:g.w
    ~height:g.h

let set_geom (w : window) (g : int32 rect) =
  w.geom <- g;
  river_sync_geom w g

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

let restore_or_seed_float (w : window) =
  match w.output with
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
          end
      in
      let g = clamp32 w g in
      w.float_geom <- Some g;
      set_geom w g
    end

let float (w : window) =
  w.presentation <- P_floating;
  restore_or_seed_float w

let toggle_floating = function
  | None -> ()
  | Some (w : window) ->
      begin if w.output <> None then
        match w.presentation with
        | P_tiled -> float w
        | P_floating when not w.is_fixed -> tile w
        | P_floating
        | P_fullscreen _ ->
            ()
      end

let is_fullscreen (w : window) =
  match w.presentation with
  | P_fullscreen _ -> true
  | _ -> false

let fullscreen (w : window) =
  match w.output with
  | None -> ()
  | Some o -> begin
      Rwm.River_window_v1.fullscreen w.obj ~output:o.obj;
      Rwm.River_window_v1.inform_fullscreen w.obj
    end

let exit_fullscreen
      (w : window)
      (p : [ `Tiled | `Floating ])
  =
  match w.output with
  | None -> ()
  | Some _ -> begin
      Rwm.River_window_v1.exit_fullscreen w.obj;
      Rwm.River_window_v1.inform_not_fullscreen w.obj;
      match p with
      | `Tiled -> tile w
      | `Floating -> float w
    end

(** [is_rendered w] is true if and only if [w] is [tag_visible] and no other
  * window is tag visible and fullscreen *)
let is_rendered (w : window) =
  tag_visible w
  &&
  match w.output with
  | None -> false
  | Some o ->
      not
        (List.exists
           (fun w' ->
              w' != w && is_fullscreen w' && tag_visible w')
           o.focus_stack)

(** [sync w] ensures [w] is shown or hidden.
    [w] is shown if [is_rendered w] is [true] and [w.is_hidden] is [true].
    [w] is hidden if [is_rendered w ] is [false] and [w.is_hidden] is [false].
    Else, state is already synced in which case [sync w] is a no-op. *)
let sync (w : window) =
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

let queue_request (w : window) (r : window_request) =
  w.requests <- r :: w.requests

let clear_requests (w : window) = w.requests <- []

let fit_to_output (w : window) =
  match w.output with
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
        set_position w ~x:new_x ~y:new_y
    end

let at_point ~(x : int32) ~(y : int32) =
  List.find_opt (fun (w : window) ->
    tag_visible w
    && Ocdwm_core.Utils.in_rect ~x ~y ~g:w.geom)
