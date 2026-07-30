open! Ocdwm_core
open! Ocdwm_state

let handle_move wm seat window =
  let aux () = Drag.begin_move wm seat window in
  match window.presentation with
  | Fullscreen _ -> ()
  | Tiled ->
    if not @@ Output.is_floating window.output
    then Window.set_presentation window Floating;
    aux ()
  | Maximized _ ->
    Window.set_presentation window Floating;
    aux ()
  | Floating -> aux ()
;;

let handle_resize wm seat window edges =
  let resize () = Drag.begin_resize wm seat window edges in
  match window.presentation with
  | Fullscreen _ -> ()
  | Tiled ->
    if not @@ Output.is_floating window.output
    then Window.set_presentation window Floating;
    resize ()
  | Maximized _ ->
    Window.set_presentation window Floating;
    resize ()
  | Floating -> resize ()
;;

let handle_set_dimensions (wm : Wm.t) window w h =
  Window.set_geom window { window.geom with w; h };
  if window.float_seed_pending
  then (
    Window.set_float_seed_pending window false;
    Window.restore_or_seed_float window);
  let in_resize =
    List.exists
      (fun (s : Seat.t) ->
         match s.op with
         | Some (Resize { window = w; _ }) when w == window -> true
         | _ -> false)
      wm.seats
  in
  if window.presentation = Floating && not in_resize then Window.fit_to_output window
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
    |> Result.iter_error @@ fun e -> Logs.warn @@ fun m -> m "%s" e
  | Resize r -> handle_resize wm r.seat window r.edges
  | Resize_to { w; h } ->
    Placement.resize_window_to ~width:w ~height:h window
    |> Result.iter_error @@ fun e -> Logs.warn @@ fun m -> m "%s" e
  | Maximize -> Placement.maximize wm window
  | Unmaximize -> Placement.unmaximize window
  | Fake_fullscreen -> Window.fake_fullscreen window
  | Exit_fake_fullscreen -> Window.exit_fake_fullscreen window
  | Fullscreen r -> Placement.fullscreen wm r.output window handle
  | Exit_fullscreen -> Placement.exit_fullscreen window
  | Dimensions d -> handle_set_dimensions wm window d.width d.height
  | Set_tags arg -> handle_set_tags wm window arg
  | Send_to_output_name { name; policy } ->
    Placement.send_window_to_name wm window name policy
    |> Result.iter_error @@ fun e -> Logs.warn @@ fun m -> m "%s" e
  | Float -> Window.float window
  | Tile -> Window.tile window
;;

let toggle_maximize wm seat =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w ->
    (match w.presentation with
     | Maximized _ ->
       handle wm w Unmaximize;
       Ok None
     | Tiled | Floating ->
       handle wm w Maximize;
       Ok None
     | Fullscreen _ -> Error "cannot toggle maximization while window is fullscreen")
;;

let toggle_fake_fullscreen wm seat =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w ->
    (match w.presentation with
     | Fullscreen _ ->
       Error "cannot toggle fake fullscreen when window is actually fullscreen"
     | _ ->
       (if w.is_fake_fullscreen then Exit_fake_fullscreen else Fake_fullscreen)
       |> handle wm w;
       Ok None)
;;

let toggle_fullscreen wm seat =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w ->
    (match w.presentation with
     | Fullscreen _ ->
       handle wm w Exit_fullscreen;
       Ok None
     | _ when Option.is_none w.output -> Error Messages.window_missing_output
     | _ ->
       handle wm w @@ Fullscreen { output = w.output };
       Ok None)
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
