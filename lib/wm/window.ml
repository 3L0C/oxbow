open! Ocdwm_core

type t = Types.Window.t

let next_id = Atomic.make 1

let fresh_id () =
  let id = Atomic.get next_id in
  Atomic.incr next_id;
  id
;;

let create
      (wm : Types.Window_manager.t)
      (river_window :
        River.V.Window_management.t River.Window_management.River_window_v1.t)
  : t
  =
  let node =
    object
      inherit [_] River.Window_management.River_node_v1.v4
    end
  in
  let output = Window_manager.default_output wm in
  { obj = river_window
  ; node = River.Window_management.River_window_v1.get_node river_window node
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
      (match output with
       | None -> Tag_set.singleton 1
       | Some o -> o.selected_tags)
  ; output
  ; is_fixed = false
  ; is_urgent = false
  ; is_fake_fullscreen = false
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
    River.Window_management.River_window_v1.destroy w.obj;
    Wayland.Proxy.delete w.obj;
    River.Window_management.River_node_v1.destroy w.node
  | _ ->
    Logs.warn
    @@ fun m -> m "destroy refused: Window is %s not closing" (state_to_string w.state)
;;

let set_position (_ : 'p Ctx.t) (w : t) ~(x : int32) ~(y : int32) =
  w.geom <- { w.geom with x; y };
  River.Window_management.River_node_v1.set_position w.node ~x ~y
;;

let river_sync_geom (_ : Ctx.manage Ctx.t) (w : t) (g : int32 Rect.t) =
  River.Window_management.River_node_v1.set_position w.node ~x:g.x ~y:g.y;
  River.Window_management.River_window_v1.propose_dimensions w.obj ~width:g.w ~height:g.h
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
      | P_floating | P_maximized _ | P_fullscreen _ -> ())
;;

let is_fullscreen (w : t) =
  match w.presentation with
  | P_fullscreen _ -> true
  | _ -> false
;;

let fullscreen ?(force : bool = false) (_ : Ctx.manage Ctx.t) (w : t) =
  match w.output with
  | None -> ()
  | Some o ->
    let enter restore =
      w.presentation <- P_fullscreen { restore };
      River.Window_management.River_window_v1.fullscreen w.obj ~output:o.obj;
      River.Window_management.River_window_v1.inform_fullscreen w.obj
    in
    (match w.presentation with
     | P_tiled -> enter `Tiled
     | P_floating -> enter `Floating
     | P_maximized { restore } ->
       River.Window_management.River_window_v1.inform_unmaximized w.obj;
       enter (`Maximized restore)
     | P_fullscreen { restore } when force -> enter restore
     | P_fullscreen _ -> ())
;;

let maximize ?restore (ctx : Ctx.manage Ctx.t) (w : t) =
  let enter restore =
    match w.output with
    | None -> ()
    | Some o ->
      let g =
        Rect.(
          Int32.
            { x = of_int o.usable.x
            ; y = of_int o.usable.y
            ; w = of_int o.usable.w
            ; h = of_int o.usable.h
            })
      in
      w.presentation <- P_maximized { restore };
      set_geom ctx w g;
      River.Window_management.River_window_v1.inform_maximized w.obj
  in
  match restore with
  | None ->
    (match w.presentation with
     | P_tiled -> enter `Tiled
     | P_floating ->
       remember_float w;
       enter `Floating
     | P_fullscreen _ | P_maximized _ -> ())
  | Some r -> enter r
;;

let unmaximize (ctx : Ctx.manage Ctx.t) (w : t) =
  match w.presentation with
  | P_tiled | P_floating | P_fullscreen _ -> ()
  | P_maximized { restore } ->
    River.Window_management.River_window_v1.inform_unmaximized w.obj;
    (match restore with
     | `Tiled -> tile w
     | `Floating -> float ctx w)
;;

let exit_fullscreen (ctx : Ctx.manage Ctx.t) (w : t) =
  match w.output, w.presentation with
  | Some _, P_fullscreen { restore } ->
    River.Window_management.River_window_v1.exit_fullscreen w.obj;
    River.Window_management.River_window_v1.inform_not_fullscreen w.obj;
    (match restore with
     | `Tiled -> tile w
     | `Floating -> float ctx w
     | `Maximized restore -> maximize ~restore ctx w)
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
    River.Window_management.River_window_v1.show w.obj;
    w.is_hidden <- false
  | false, false ->
    River.Window_management.River_window_v1.hide w.obj;
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

let fake_fullscreen (ctx : Ctx.manage Ctx.t) (w : t) =
  if not w.is_fake_fullscreen
  then (
    w.is_fake_fullscreen <- true;
    River.Window_management.River_window_v1.inform_fullscreen w.obj)
;;

let exit_fake_fullscreen (ctx : Ctx.manage Ctx.t) (w : t) =
  if w.is_fake_fullscreen
  then (
    w.is_fake_fullscreen <- false;
    River.Window_management.River_window_v1.inform_not_fullscreen w.obj)
;;

let float_in_place (w : t) =
  match w.presentation with
  | P_floating -> ()
  | P_fullscreen _ -> Logs.err @@ fun m -> m "unable to float fullscreen window"
  | P_tiled | P_maximized _ ->
    remember_float w;
    w.presentation <- P_floating
;;

let apply_float_geom ctx w g =
  clamp w g |> set_geom ctx w;
  remember_float w
;;

let move_to (ctx : Ctx.manage Ctx.t) (w : t) ~x ~y =
  if is_fullscreen w
  then Logs.err @@ fun m -> m "unable to move fullscreen window"
  else (
    match w.output with
    | None -> ()
    | Some o ->
      float_in_place w;
      let cur = Rect.to_int w.geom in
      let g =
        { cur with
          x = o.usable.x + Extent.resolve x ~ref:o.usable.w
        ; y = o.usable.y + Extent.resolve y ~ref:o.usable.h
        }
      in
      apply_float_geom ctx w g)
;;

let move_spatial ctx (w : t) (dir : Spatial_direction.t) by =
  if is_fullscreen w
  then Logs.err @@ fun m -> m "unable to move fullscreen window"
  else (
    match w.output with
    | None -> ()
    | Some o ->
      float_in_place w;
      let cur = Rect.to_int w.geom in
      let dx = Extent.resolve by ~ref:o.usable.w in
      let dy = Extent.resolve by ~ref:o.usable.h in
      let g =
        match dir with
        | Up -> { cur with y = cur.y - dy }
        | Down -> { cur with y = cur.y + dy }
        | Left -> { cur with x = cur.x - dx }
        | Right -> { cur with x = cur.x + dx }
      in
      apply_float_geom ctx w g)
;;

let resize_to ctx (w : t) ~width ~height =
  if is_fullscreen w
  then Logs.err @@ fun m -> m "unable to resize fullscreen window"
  else (
    match w.output with
    | None -> ()
    | Some o ->
      float_in_place w;
      let cur = Rect.to_int w.geom in
      let g =
        { cur with
          w = Extent.resolve width ~ref:o.usable.w
        ; h = Extent.resolve height ~ref:o.usable.h
        }
      in
      apply_float_geom ctx w g)
;;

let resize_spatial ctx (w : t) (dir : Spatial_direction.t) by =
  if is_fullscreen w
  then Logs.err @@ fun m -> m "unable to resize fullscreen window"
  else (
    match w.output with
    | None -> ()
    | Some o ->
      float_in_place w;
      let cur = Rect.to_int w.geom in
      let dx = Extent.resolve by ~ref:o.usable.w in
      let dy = Extent.resolve by ~ref:o.usable.h in
      let g =
        match dir with
        | Up -> { cur with y = cur.y - dy; h = cur.h + dy }
        | Down -> { cur with h = cur.h + dy }
        | Left -> { cur with x = cur.x - dx; w = cur.w + dx }
        | Right -> { cur with w = cur.w + dx }
      in
      apply_float_geom ctx w g)
;;
