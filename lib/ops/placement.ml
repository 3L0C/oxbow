open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_ipc
open! Ocdwm_layout

let zoom ?warp ctx (seat : Seat.t) =
  With.focused_output seat
  @@ fun o ->
  match Output.current_layout o with
  | Floating -> Error "cannot zoom in the floating layout"
  | Scrolling -> Column.zoom ?warp ctx seat
  | Tiling -> Tiling.zoom ?warp ctx seat
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
  With.output window
  @@ fun current ->
  let wm = Ctx.wm ctx in
  let target = Output.resolve_output_logical ~dir current wm.outputs in
  match target with
  | Some o when o != current ->
    send_to ~src:current ~dst:o ctx window policy;
    Ok None
  | _ -> Error Messages.no_other_output
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
  With.output window
  @@ fun current ->
  if Output.matches_name name current
  then Ok None
  else (
    let wm = Ctx.wm ctx in
    let target = Output.resolve_output_name name wm.outputs in
    match target with
    | Some o when o != current ->
      send_to ~src:current ~dst:o ctx window policy;
      Ok None
    | _ -> Error (Printf.sprintf "no output named %S" name))
;;

let send_to_logical ctx seat dir policy ~follow =
  With.focused_window seat
  @@ fun _o w ->
  match send_window_to_logical ctx w dir policy with
  | Ok _ as result when follow ->
    Focus.focus_window ~force:true ~warp:Seat.Warp_request.Follow_config ctx seat w;
    result
  | result -> result
;;

let send_to_spatial ctx seat dir policy ~follow =
  With.focused_window seat
  @@ fun _o w ->
  match send_window_to_spatial ctx w dir policy with
  | Ok _ as result when follow ->
    Focus.focus_window ~force:true ~warp:Seat.Warp_request.Follow_config ctx seat w;
    result
  | result -> result
;;

let send_to_name ctx seat name policy ~follow =
  With.focused_window seat
  @@ fun _o w ->
  match send_window_to_name ctx w name policy with
  | Ok _ as result when follow ->
    Focus.focus_window ~force:true ~warp:Seat.Warp_request.Follow_config ctx seat w;
    result
  | result -> result
;;

let toggle_floating ctx seat =
  With.focused_window seat
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
  With.focused_window seat
  @@ fun _o w ->
  River.Window_management.River_window_v1.close w.obj;
  Ok None
;;

let move_to ~x ~y ctx seat =
  With.focused_window seat
  @@ fun o w ->
  if Window.is_fullscreen w
  then Error "cannot move a fullscreen window"
  else (
    Window.move_to ctx w ~x ~y;
    Option.iter Dirty.mark_output w.output;
    Ok None)
;;

let move_spatial ctx seat dir by =
  With.focused_window seat
  @@ fun o w ->
  if Window.is_fullscreen w
  then Error "cannot move a fullscreen window"
  else (
    Window.move_spatial ctx w dir by;
    Option.iter Dirty.mark_output w.output;
    Ok None)
;;

let resize_to ~width ~height ctx seat =
  With.focused_window seat
  @@ fun o w ->
  if Window.is_fullscreen w
  then Error "cannot resize a fullscreen window"
  else (
    Window.resize_to ctx w ~width ~height;
    Option.iter Dirty.mark_output w.output;
    Ok None)
;;

let resize_spatial ctx seat dir by =
  With.focused_window seat
  @@ fun o w ->
  if Window.is_fullscreen w
  then Error "cannot resize a fullscreen window"
  else (
    Window.resize_spatial ctx w dir by;
    Option.iter Dirty.mark_output w.output;
    Ok None)
;;

let swap_outputs ctx seat ~(target : Command.Output.Swap.Target.t) ~policy ~follow scope =
  With.focused_output seat
  @@ fun current ->
  let wm = Ctx.wm ctx in
  let with_named_output name f =
    match List.find_opt (fun (o : Output.t) -> Output.matches_name name o) wm.outputs with
    | None -> Error (Printf.sprintf "no output name matching %S" name)
    | Some o -> f o
  in
  let pair =
    match target with
    | Pair { first; second } ->
      (match first, second with
       | None, None ->
         (match wm.outputs with
          | [ a; b ] -> if a == current then Ok (a, b) else Ok (b, a)
          | os ->
            Error (Printf.sprintf "needs exactly two outputs, have %d" (List.length os)))
       | Some n, None -> with_named_output n @@ fun a -> Ok (current, a)
       | Some n, Some n' ->
         with_named_output n @@ fun a -> with_named_output n' @@ fun b -> Ok (a, b)
       | None, Some _ -> Error "swap needs a first output name before a second")
    | Ring { members; rev } ->
      let resolve name = List.find_opt (Output.matches_name name) wm.outputs in
      let live = List.filter_map resolve members in
      if List.length live < 2
      then Error "the ring needs two connect outputs"
      else if not @@ List.memq current live
      then Error "the focused output is not in the ring"
      else (
        let dest =
          Option.get
          @@
          if rev then Ring.prev_or_last current live else Ring.next_or_first current live
        in
        Ok (current, dest))
  in
  match pair with
  | Error _ as e -> e
  | Ok (a, b) when a == b -> Error "cannot swap an output with itself"
  | Ok (a, b) ->
    let in_scope =
      match scope with
      | `Tags ->
        fun (o : Output.t) ->
          if o == a
          then Output.visible_windows a
          else Output.windows_on_tags b ~tags:a.selected_tags
      | `All -> fun (o : Output.t) -> o.wm_stack
      | `Visible -> Output.visible_windows
    in
    let a_focus = a.focus_stack
    and b_focus = b.focus_stack
    and a_ws = in_scope a |> List.rev
    and b_ws = in_scope b |> List.rev in
    List.iter (fun w -> send_to ~src:a ~dst:b ctx w policy) a_ws;
    List.iter (fun w -> send_to ~src:b ~dst:a ctx w policy) b_ws;
    Stacking.restore_focus_order ~like:a_focus b;
    Stacking.restore_focus_order ~like:b_focus a;
    if follow then Focus.focus_output ctx seat b;
    Ok None
;;
