open! Ocdwm_core
include Types.Window

module Lifecycle = struct
  include Types.Window.Lifecycle

  let to_string = function
    | New -> "new"
    | Active -> "active"
    | Closing -> "closing"
  ;;
end

let next_id = Atomic.make 1

let fresh_id () =
  let id = Atomic.get next_id in
  Atomic.incr next_id;
  id
;;

let create (output : Types.Output.t option) river_window : t =
  let node =
    object
      inherit [_] River.Window_management.River_node_v1.v4
    end
  in
  { obj = river_window
  ; node = River.Window_management.River_window_v1.get_node river_window node
  ; lifecycle = New
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
       | None -> Tag.Set.singleton 1
       | Some o -> o.selected_tags)
  ; output
  ; output_before_evac = None
  ; is_fixed = false
  ; is_urgent = false
  ; is_fake_fullscreen = false
  ; is_hidden = false
  ; presentation = Presentation.Tiled
  ; requests = []
  }
;;

let destroy (w : t) =
  match w.lifecycle with
  | Closing ->
    River.Window_management.River_window_v1.destroy w.obj;
    Wayland.Proxy.delete w.obj;
    River.Window_management.River_node_v1.destroy w.node
  | _ ->
    Logs.warn
    @@ fun m ->
    m "destroy refused: Window is %s not closing" (Lifecycle.to_string w.lifecycle)
;;

let set_position (_ : 'p Ctx.t) (w : t) ~(x : int32) ~(y : int32) =
  w.geom <- { w.geom with x; y };
  River.Window_management.River_node_v1.set_position w.node ~x ~y
;;

let river_sync_geom (_ : Ctx.manage Ctx.t) (w : t) (g : int32 Rect.t) =
  River.Window_management.River_node_v1.set_position w.node ~x:g.x ~y:g.y;
  River.Window_management.River_window_v1.propose_dimensions w.obj ~width:g.w ~height:g.h
;;

let set_geom ctx (w : t) g =
  w.geom <- g;
  river_sync_geom ctx w g
;;

let tag_visible (w : t) =
  match w.output with
  | Some o -> Tag.Set.intersects w.tags o.selected_tags
  | None -> false
;;

let is_tiled (w : t) = w.presentation = Tiled
let remember_float (w : t) = w.float_geom <- Some w.geom

let tile (w : t) =
  if w.presentation = Floating then remember_float w;
  w.presentation <- Tiled
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
  w.presentation <- Floating;
  restore_or_seed_float ctx w
;;

let is_fullscreen (w : t) =
  match w.presentation with
  | Fullscreen _ -> true
  | _ -> false
;;

let fullscreen ?(force : bool = false) (_ : Ctx.manage Ctx.t) (w : t) =
  match w.output with
  | None -> ()
  | Some o ->
    let enter restore =
      w.presentation <- Fullscreen { restore };
      River.Window_management.River_window_v1.fullscreen w.obj ~output:o.obj;
      River.Window_management.River_window_v1.inform_fullscreen w.obj
    in
    (match w.presentation with
     | Tiled -> enter `Tiled
     | Floating -> enter `Floating
     | Maximized { restore } ->
       River.Window_management.River_window_v1.inform_unmaximized w.obj;
       enter (`Maximized restore)
     | Fullscreen { restore } when force -> enter restore
     | Fullscreen _ -> ())
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
      w.presentation <- Maximized { restore };
      set_geom ctx w g;
      River.Window_management.River_window_v1.inform_maximized w.obj
  in
  match restore with
  | None ->
    (match w.presentation with
     | Tiled -> enter `Tiled
     | Floating ->
       remember_float w;
       enter `Floating
     | Fullscreen _ | Maximized _ -> ())
  | Some r -> enter r
;;

let unmaximize (ctx : Ctx.manage Ctx.t) (w : t) =
  match w.presentation with
  | Tiled | Floating | Fullscreen _ -> ()
  | Maximized { restore } ->
    River.Window_management.River_window_v1.inform_unmaximized w.obj;
    (match restore with
     | `Tiled -> tile w
     | `Floating -> float ctx w)
;;

let exit_fullscreen (ctx : Ctx.manage Ctx.t) (w : t) =
  match w.output, w.presentation with
  | Some _, Fullscreen { restore } ->
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

let sync (ctx : Ctx.manage Ctx.t) (w : t) =
  let wm = Ctx.wm ctx in
  let moving =
    List.exists
      (fun (s : Types.Seat.t) ->
         match s.op with
         | Some (Move { window; _ }) when window == w -> true
         | _ -> false)
      wm.seats
  in
  let should_render = is_rendered w in
  match should_render, w.is_hidden with
  | true, true ->
    River.Window_management.River_window_v1.show w.obj;
    w.is_hidden <- false
  | false, false when not moving ->
    River.Window_management.River_window_v1.hide w.obj;
    w.is_hidden <- true
  | _, _ -> ()
;;

let queue_request wm (w : t) request =
  w.requests <- request :: w.requests;
  Dirty.mark_wm wm
;;

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
  List.find_opt (fun (w : t) -> tag_visible w && Rect.contains ~x ~y w.geom)
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
  | Floating -> ()
  | Fullscreen _ -> Logs.err @@ fun m -> m "unable to float fullscreen window"
  | Tiled | Maximized _ ->
    remember_float w;
    w.presentation <- Floating
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

let move_spatial ctx (w : t) (dir : Direction.Spatial.t) by =
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

let resize_spatial ctx (w : t) (dir : Direction.Spatial.t) by =
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

let set_tags (w : t) tags =
  if not @@ Tag.Set.is_empty tags
  then (
    w.tags <- tags;
    Option.iter Dirty.mark_output w.output)
  else invalid_arg "Windows cannot have an empty set of tags."
;;

let set_output (w : t) output =
  let aux () =
    Option.iter Dirty.mark_output w.output;
    Option.iter Dirty.mark_output output;
    w.output <- output
  in
  match w.output, output with
  | Some o, None when Option.is_none w.output_before_evac ->
    w.output_before_evac <- o.name;
    aux ()
  | _ -> aux ()
;;

let set_presentation (w : t) presentation =
  w.presentation <- presentation;
  Option.iter Dirty.mark_output w.output
;;

let set_is_urgent (w : t) is_urgent =
  w.is_urgent <- is_urgent;
  Option.iter Dirty.mark_output w.output
;;

let set_lifecycle (w : t) lifecycle = w.lifecycle <- lifecycle
let set_title (w : t) title = w.title <- title
let set_app_id (w : t) app_id = w.app_id <- app_id
let set_identifier (w : t) identifier = w.identifier <- identifier
let set_unreliable_pid (w : t) pid = w.unreliable_pid <- pid
let set_parent (w : t) parent = w.parent <- parent
let set_decoration_hint (w : t) hint = w.decoration_hint <- hint
let set_presentation_hint (w : t) hint = w.presentation_hint <- hint
let set_size_hints (w : t) hints = w.size_hints <- hints
let set_is_fixed (w : t) is_fixed = w.is_fixed <- is_fixed
let set_is_hidden (w : t) is_hidden = w.is_hidden <- is_hidden

let rehome wm (w : t) name =
  match w.output_before_evac with
  | Some n when String.equal n name ->
    w.output_before_evac <- None;
    queue_request wm w @@ Send_to_output_name { name; policy = Tag.Policy.Keep }
  | _ -> ()
;;

let presentation_string (w : t) =
  match w.presentation with
  | Tiled -> "tiled"
  | Floating -> "floating"
  | Maximized _ -> "maximized"
  | Fullscreen _ -> "fullscreen"
;;
