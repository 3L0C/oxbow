open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_layout

let zoom ?warp ctx (seat : Seat.t) =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    (match Output.current_layout o with
     | Floating -> Error "cannot zoom in the floating layout"
     | Scrolling -> Column.zoom ?warp ctx seat
     | Tiling -> Tiling.zoom ?warp ctx seat)
;;

let move_window ?(policy = Tag.Policy.Keep) window (target : Output.t) =
  let take () =
    (match policy with
     | Keep -> ()
     | Take ->
       Tag.Set.first target.selected_tags
       |> Option.fold ~none:window.tags ~some:Tag.Set.singleton
       |> Window.set_tags window);
    Window.set_output window @@ Some target;
    Stacking.push [ window ] target
  in
  match window.output with
  | Some o when o == target -> ()
  | None -> take ()
  | Some o ->
    Option.iter (Stacking.remove_window ~window) window.output;
    take ()
;;

let send_to ~(src : Output.t) ~(dst : Output.t) ctx window policy =
  move_window ~policy window dst;
  (match window.presentation with
   | Tiled -> ()
   | Floating ->
     let dx = Int32.sub dst.geom.x src.geom.x in
     let dy = Int32.sub dst.geom.y src.geom.y in
     Window.set_position
       ctx
       window
       ~x:(Int32.add window.geom.x dx)
       ~y:(Int32.add window.geom.y dy);
     Window.fit_to_output ctx window;
     Window.remember_float window
   | Maximized { restore } -> Window.maximize ~restore ctx window
   | Fullscreen _ -> Window.fullscreen ~force:true ctx window);
  Dirty.mark_output src;
  Dirty.mark_output dst
;;

let send_window_to_logical ctx (window : Window.t) (dir : Direction.Logical.t) policy =
  let wm = Ctx.wm ctx in
  match window.output with
  | None -> Error Messages.window_missing_output
  | Some current ->
    let target = Output.resolve_output_logical ~dir current wm.outputs in
    (match target with
     | Some o when o != current ->
       send_to ~src:current ~dst:o ctx window policy;
       Ok None
     | _ -> Error Messages.no_other_output)
;;

let send_window_to_spatial ctx (window : Window.t) (dir : Direction.Spatial.t) policy =
  let wm = Ctx.wm ctx in
  match window.output with
  | None -> Error Messages.window_missing_output
  | Some current ->
    let from = Output.to_vector current in
    let target = Output.resolve_output_spatial ~from ~dir current wm.outputs in
    (match target with
     | Some o when o != current ->
       send_to ~src:current ~dst:o ctx window policy;
       Ok None
     | _ -> Error (Printf.sprintf "no output %s" (Direction.Spatial.to_string dir)))
;;

let send_window_to_name ctx (window : Window.t) name policy =
  let wm = Ctx.wm ctx in
  match window.output with
  | None -> Error Messages.window_missing_output
  | Some current when Output.matches_name name current -> Ok None
  | Some current ->
    let target = Output.resolve_output_name name wm.outputs in
    (match target with
     | Some o when o != current ->
       send_to ~src:current ~dst:o ctx window policy;
       Ok None
     | _ -> Error (Printf.sprintf "no output named %S" name))
;;

let send_to_logical ctx seat dir policy =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w -> send_window_to_logical ctx w dir policy
;;

let send_to_spatial ctx seat dir policy =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w -> send_window_to_spatial ctx w dir policy
;;

let send_to_name ctx seat name policy =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w -> send_window_to_name ctx w name policy
;;

let with_focused_ctx (seat : Seat.t) f =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o ->
    (match Output.focused_window o with
     | None -> Error Messages.no_focused_window
     | Some w -> f o w)
;;

let toggle_floating ctx seat =
  with_focused_ctx seat
  @@ fun o w ->
  if Output.current_layout o = Floating
  then Error "cannot toggle floating from the floating layout"
  else if o.overview
  then Error "cannot toggle floating from overview"
  else (
    match w.presentation with
    | Fullscreen _ -> Error "cannot toggle float while window is fullscreen"
    | Maximized _ -> Error "cannot toggle float while window is maximized"
    | Floating when w.is_fixed -> Error "cannot tile a fixed window"
    | Tiled ->
      Window.float ctx w;
      Dirty.mark_output o;
      Ok None
    | Floating ->
      Window.tile w;
      Dirty.mark_output o;
      Ok None)
;;

let maximize ctx window =
  let wm = Ctx.wm ctx in
  List.iter (Seat.op_end ctx) wm.seats;
  Window.maximize ctx window;
  Option.iter Dirty.mark_output window.output
;;

let unmaximize ctx window =
  Window.unmaximize ctx window;
  Option.iter Dirty.mark_output window.output
;;

let fullscreen ctx output (window : Window.t) cb =
  let wm = Ctx.wm ctx in
  let enter () =
    match output, window.output with
    | None, None -> ()
    | Some o, _ | None, Some o ->
      List.iter
        (fun w ->
           if Window.tag_visible w && Window.is_fullscreen w
           then cb ctx w Window.Request.Exit_fullscreen)
        o.focus_stack;
      List.iter (Seat.op_end ctx) wm.seats;
      Option.iter Dirty.mark_output window.output;
      move_window window o;
      Dirty.mark_output o;
      Window.fullscreen ctx window
  in
  match window.presentation with
  | Tiled | Floating | Maximized _ -> enter ()
  | Fullscreen _ ->
    (match output, window.output with
     | Some o1, Some o2 when o1 != o2 ->
       Dirty.mark_output o2;
       move_window window o1;
       Dirty.mark_output o1;
       Window.fullscreen ~force:true ctx window
     | _, _ -> ())
;;

let exit_fullscreen ctx (window : Window.t) =
  match window.presentation with
  | Tiled | Floating | Maximized _ -> ()
  | Fullscreen _ ->
    Window.exit_fullscreen ctx window;
    Option.iter Dirty.mark_output window.output
;;

let close_focused seat =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some window ->
    River.Window_management.River_window_v1.close window.obj;
    Ok None
;;

let move_to ~x ~y ctx seat =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w ->
    if Window.is_fullscreen w
    then Error "cannot move a fullscreen window"
    else (
      Window.move_to ctx w ~x ~y;
      Option.iter Dirty.mark_output w.output;
      Ok None)
;;

let move_spatial ctx seat dir by =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w ->
    if Window.is_fullscreen w
    then Error "cannot move a fullscreen window"
    else (
      Window.move_spatial ctx w dir by;
      Option.iter Dirty.mark_output w.output;
      Ok None)
;;

let resize_to ~width ~height ctx seat =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w ->
    if Window.is_fullscreen w
    then Error "cannot resize a fullscreen window"
    else (
      Window.resize_to ctx w ~width ~height;
      Option.iter Dirty.mark_output w.output;
      Ok None)
;;

let resize_spatial ctx seat dir by =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w ->
    if Window.is_fullscreen w
    then Error "cannot resize a fullscreen window"
    else (
      Window.resize_spatial ctx w dir by;
      Option.iter Dirty.mark_output w.output;
      Ok None)
;;
