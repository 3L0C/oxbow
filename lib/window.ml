module Rwm = Ocdwm_protocol.River_window_management_v1_client

type t = Types.Window.t

let next_id = Atomic.make 1

let fresh_id () =
  let id = Atomic.get next_id in
  Atomic.incr next_id;
  id
;;

let create (wm : Types.Window_manager.t) (river_window : [ `V4 ] Rwm.River_window_v1.t)
  : t
  =
  let node =
    object
      inherit [_] Rwm.River_node_v1.v4
    end
  in
  { obj = river_window
  ; node = Rwm.River_window_v1.get_node river_window node
  ; state = W_new
  ; id = fresh_id ()
  ; app_id = None
  ; title = None
  ; identifier = None
  ; unreliable_pid = None
  ; parent = { body = None }
  ; decoration_hint = None
  ; presentation_hint = None
  ; geom = { x = 0l; y = 0l; w = 0l; h = 0l }
  ; float_geom = None
  ; size_hints = { min_w = 0l; max_w = 0l; min_h = 0l; max_h = 0l }
  ; tags =
      (match wm.focused_output with
       | None -> Tag_set.singleton 1
       | Some o -> o.selected_tags)
  ; output = wm.focused_output
  ; is_fixed = false
  ; is_urgent = false
  ; is_maximized = false
  ; is_hidden = false
  ; presentation = P_tiled
  ; requests = []
  }
;;

let state_to_string (state : Window_state.t) =
  match state with
  | W_new -> "new"
  | W_active -> "active"
  | W_dirty _ -> "dirty"
  | W_closing -> "closing"
;;

let destroy (w : t) =
  match w.state with
  | W_closing ->
    Rwm.River_window_v1.destroy w.obj;
    Wayland.Proxy.delete w.obj;
    Rwm.River_node_v1.destroy w.node
  | _ ->
    Logs.warn (fun m ->
      m "destroy refused: Window is %s not closing." (state_to_string w.state))
;;

let set_position (_ : 'p Ctx.t) (w : t) ~(x : int32) ~(y : int32) =
  w.geom <- { w.geom with x; y };
  Rwm.River_node_v1.set_position w.node ~x ~y
;;

let river_sync_geom (_ : Ctx.manage Ctx.t) (w : t) (g : int32 Rect.t) =
  Rwm.River_node_v1.set_position w.node ~x:g.x ~y:g.y;
  Rwm.River_window_v1.propose_dimensions w.obj ~width:g.w ~height:g.h
;;

let set_geom (ctx : Ctx.manage Ctx.t) (w : t) (g : int32 Rect.t) =
  w.geom <- g;
  river_sync_geom ctx w g
;;

let tag_visible (w : t) =
  match w.output with
  | Some o -> Tag_set.intersects w.tags o.selected_tags
  | None -> false
;;

let is_tiled (w : t) = w.presentation = P_tiled
let remember_float (w : t) = w.float_geom <- Some w.geom

let tile (w : t) =
  if w.presentation = P_floating then remember_float w;
  w.presentation <- P_tiled
;;

let clamp_dim ~min_v ~max_v v =
  v
  |> (if min_v > 0l then Int32.max min_v else Fun.id)
  |> if max_v > 0l then Int32.min max_v else Fun.id
;;

let clamp (w : t) (g : int Rect.t) =
  let h = w.size_hints in
  Rect.(
    Int32.
      { x = of_int g.x
      ; y = of_int g.y
      ; w = of_int g.w |> clamp_dim ~min_v:h.min_w ~max_v:h.max_w
      ; h = of_int g.h |> clamp_dim ~min_v:h.min_h ~max_v:h.max_h
      })
;;

let clamp32 (w : t) (g : int32 Rect.t) =
  let h = w.size_hints in
  Rect.(
    Int32.
      { x = g.x
      ; y = g.y
      ; w = clamp_dim ~min_v:h.min_w ~max_v:h.max_w g.w
      ; h = clamp_dim ~min_v:h.min_h ~max_v:h.max_h g.h
      })
;;

let restore_or_seed_float (ctx : Ctx.manage Ctx.t) (w : t) =
  match w.output with
  | None -> ()
  | Some o ->
    let g =
      match w.float_geom with
      | Some g -> g
      | None ->
        let usable =
          Rect.(
            Int32.
              { x = of_int o.usable.x
              ; y = of_int o.usable.y
              ; w = of_int o.usable.w
              ; h = of_int o.usable.h
              })
        in
        Rect.(
          Int32.
            { x = div usable.w 4l |> add usable.x
            ; y = div usable.h 4l |> add usable.y
            ; w = div usable.w 2l
            ; h = div usable.h 2l
            })
        |> clamp32 w
    in
    w.float_geom <- Some g;
    set_geom ctx w g
;;

let float (ctx : Ctx.manage Ctx.t) (w : t) =
  w.presentation <- P_floating;
  restore_or_seed_float ctx w
;;

let toggle_floating (ctx : Ctx.manage Ctx.t) (window : t option) =
  match window with
  | None -> ()
  | Some (w : t) ->
    if w.output <> None
    then (
      match w.presentation with
      | P_tiled -> float ctx w
      | P_floating when not w.is_fixed -> tile w
      | P_floating | P_fullscreen _ -> ())
;;

let is_fullscreen (w : t) =
  match w.presentation with
  | P_fullscreen _ -> true
  | _ -> false
;;

let fullscreen (_ : Ctx.manage Ctx.t) (w : t) (r : [ `Tiled | `Floating ]) =
  match w.output with
  | None -> ()
  | Some o ->
    w.presentation <- P_fullscreen { restore = r };
    Rwm.River_window_v1.fullscreen w.obj ~output:o.obj;
    Rwm.River_window_v1.inform_fullscreen w.obj
;;

let exit_fullscreen (ctx : Ctx.manage Ctx.t) (w : t) (p : [ `Tiled | `Floating ]) =
  match w.output, w.presentation with
  | Some _, P_fullscreen _ ->
    Rwm.River_window_v1.exit_fullscreen w.obj;
    Rwm.River_window_v1.inform_not_fullscreen w.obj;
    (match p with
     | `Tiled -> tile w
     | `Floating -> float ctx w)
  | _ -> ()
;;

let is_rendered (w : t) =
  tag_visible w
  &&
  match w.output with
  | None -> false
  | Some o ->
    not
    @@ List.exists (fun w' -> w' != w && is_fullscreen w' && tag_visible w') o.focus_stack
;;

let sync (_ : 'p Ctx.t) (w : t) =
  let should_render = is_rendered w in
  match should_render, w.is_hidden with
  | true, true ->
    Rwm.River_window_v1.show w.obj;
    w.is_hidden <- false
  | false, false ->
    Rwm.River_window_v1.hide w.obj;
    w.is_hidden <- true
  | _, _ -> ()
;;

let queue_request (w : t) (r : Types.Window_request.t) = w.requests <- r :: w.requests
let clear_requests (w : t) = w.requests <- []

let fit_to_output (ctx : 'p Ctx.t) (w : t) =
  match w.output with
  | None -> ()
  | Some o ->
    let new_x =
      if w.geom.w > o.geom.w
      then o.geom.x
      else (
        let max_x = Int32.(sub o.geom.w w.geom.w |> add o.geom.x) in
        Int32.(w.geom.x |> max o.geom.x |> min max_x))
    in
    let new_y =
      if w.geom.h > o.geom.h
      then o.geom.y
      else (
        let max_y = Int32.(sub o.geom.h w.geom.h |> add o.geom.y) in
        Int32.(w.geom.y |> max o.geom.y |> min max_y))
    in
    if new_x <> w.geom.x || new_y <> w.geom.y then set_position ctx w ~x:new_x ~y:new_y
;;

let at_point ~(x : int32) ~(y : int32) =
  List.find_opt (fun (w : t) -> tag_visible w && Utils.in_rect ~x ~y ~g:w.geom)
;;
