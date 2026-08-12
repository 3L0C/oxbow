open! Oxbow_core
open! Oxbow_state

let float_then (window : Window.t) f =
  match window.presentation with
  | Fullscreen _ -> ()
  | Tiled ->
    if not @@ Output.is_floating window.output
    then Window.set_presentation window Floating;
    f ()
  | Maximized _ ->
    Window.set_presentation window Floating;
    f ()
  | Floating -> f ()
;;

let handle_move wm seat (window : Window.t) =
  let from_tiled =
    match window.presentation with
    | Tiled -> not @@ Output.is_floating window.output
    | Floating | Maximized _ | Fullscreen _ -> false
  in
  Column.detach window;
  float_then window @@ fun () -> Drag.begin_move wm seat window ~from_tiled
;;

let handle_resize wm seat window edges =
  float_then window @@ fun () -> Drag.begin_resize wm seat window edges
;;

let handle_set_dimensions (wm : Wm.t) window w h =
  if Output.arranges window
  then (
    Log.warn (fun m ->
      m
        "%s requested dimensions changed while tiling"
        (Option.value ~default:"?" window.app_id));
    Window.reject_dimensions window ~width:w ~height:h)
  else (
    Window.set_geom window { window.geom with w; h };
    if window.float_seed_pending then Window.restore_or_seed_float window;
    let in_resize =
      List.exists
        (fun (s : Seat.t) ->
           match s.op with
           | Some (Resize { window = w; _ }) when w == window -> true
           | _ -> false)
        wm.seats
    in
    if window.presentation = Floating && not in_resize then Window.fit_to_output window)
;;

let handle_set_tags _wm window (arg : Tag.Arg.t) =
  let set_tags s = Window.set_tags window s in
  match window.output, arg with
  | Some o, _ -> Output.resolve_tag_arg ~arg o |> set_tags
  | None, Concrete s -> set_tags s
  | None, Occupied -> ()
;;

let rec handle wm window (request : Window.Request.t) =
  match request with
  | Move r -> handle_move wm r.seat window
  | Move_to { x; y } ->
    Placement.move_window_to ~x ~y window
    |> Result.iter_error @@ fun e -> Log.warn @@ fun m -> m "%s" e
  | Resize r -> handle_resize wm r.seat window r.edges
  | Resize_to { w; h } ->
    Placement.resize_window_to ~width:w ~height:h window
    |> Result.iter_error @@ fun e -> Log.warn @@ fun m -> m "%s" e
  | Maximize -> Placement.maximize wm window
  | Unmaximize -> Placement.unmaximize window
  | Fake_fullscreen -> Window.fake_fullscreen window
  | Exit_fake_fullscreen -> Window.exit_fake_fullscreen window
  | Fullscreen r -> Placement.fullscreen wm r.output window handle
  | Exit_fullscreen -> Placement.exit_fullscreen window
  | Dimensions d -> handle_set_dimensions wm window d.width d.height
  | Set_tags arg -> handle_set_tags wm window arg
  | Set_sticky scope -> Window.set_sticky window scope
  | Send_to_output_name { name; policy } ->
    Result.iter_error (fun e -> Log.warn @@ fun m -> m "%s" e)
    @@ Placement.send_window_to_name wm window name policy
  | Float -> Window.float window
  | Tile -> Window.tile window
;;

let toggle_maximize wm seat target =
  Result.map (fun _ -> None)
  @@ Targets.transact_one_window wm seat target ~plan:(fun w ->
    match w.presentation with
    | Maximized _ -> Ok (fun () -> handle wm w Unmaximize)
    | Tiled | Floating -> Ok (fun () -> handle wm w Maximize)
    | Fullscreen _ -> Error "cannot toggle maximization while window is fullscreen")
;;

let toggle_fake_fullscreen wm seat target =
  Result.map (fun _ -> None)
  @@ Targets.transact_all_windows wm seat target ~plan:(fun w ->
    match w.presentation with
    | Fullscreen _ ->
      Error "cannot toggle fake fullscreen when window is actually fullscreen"
    | _ ->
      Ok
        (fun () ->
          (if w.is_fake_fullscreen then Exit_fake_fullscreen else Fake_fullscreen)
          |> handle wm w))
;;

let toggle_fullscreen wm seat target =
  Result.map (fun _ -> None)
  @@ Targets.transact_one_window wm seat target ~plan:(fun w ->
    match w.presentation with
    | Fullscreen _ -> Ok (fun () -> handle wm w Exit_fullscreen)
    | _ when Option.is_none w.output -> Error Messages.window_missing_output
    | _ -> Ok (fun () -> handle wm w @@ Fullscreen { output = w.output }))
;;

let move_interactive wm (seat : Seat.t) =
  match seat.op, seat.hovered with
  | Some _, _ -> Error "cannot begin move during an active operation"
  | None, None -> Error "no hovered window"
  | None, Some w when Window.is_fullscreen w -> Error "cannot move a fullscreen window"
  | None, Some w ->
    handle wm w @@ Move { seat };
    Ok None
;;

let resize_interactive wm (seat : Seat.t) =
  match seat.op, seat.hovered with
  | Some _, _ -> Error "cannot begin resize during an active operation"
  | None, None -> Error "no hovered window"
  | None, Some w when Window.is_fullscreen w -> Error "cannot resize a fullscreen window"
  | None, Some w ->
    let g = w.geom in
    let open Wire in
    let horiz =
      if Int32.(compare seat.position.x (add g.x (div g.w 2l))) < 0
      then Edges.left
      else Edges.right
    in
    let vert =
      if Int32.(compare seat.position.y (add g.y (div g.h 2l))) < 0
      then Edges.top
      else Edges.bottom
    in
    handle wm w (Resize { seat; edges = Int32.logor horiz vert });
    Ok None
;;
