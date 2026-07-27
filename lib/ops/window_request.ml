open! Ocdwm_core
open! Ocdwm_state

let handle_move ctx seat window =
  let aux () = Drag.begin_move ctx seat window in
  match window.presentation with
  | Fullscreen _ -> ()
  | Tiled ->
    if not @@ Output.is_floating window.output
    then Window.set_presentation window Floating;
    aux ()
  | Maximized _ ->
    Window.set_presentation window Floating;
    Send.inform_unmaximized ctx window;
    aux ()
  | Floating -> aux ()
;;

let handle_resize ctx seat window edges =
  let resize () = Drag.begin_resize ctx seat window edges in
  match window.presentation with
  | Fullscreen _ -> ()
  | Tiled ->
    if not @@ Output.is_floating window.output
    then Window.set_presentation window Floating;
    resize ()
  | Maximized _ ->
    Window.set_presentation window Floating;
    Send.inform_unmaximized ctx window;
    resize ()
  | Floating -> resize ()
;;

let handle_set_dimensions ctx window w h =
  let wm = Ctx.wm ctx in
  Window.set_geom ctx window { window.geom with w; h };
  if window.float_seed_pending
  then (
    Window.set_float_seed_pending window false;
    Window.restore_or_seed_float ctx window);
  let in_resize =
    List.exists
      (fun (s : Seat.t) ->
         match s.op with
         | Some (Resize { window = w; _ }) when w == window -> true
         | _ -> false)
      wm.seats
  in
  if window.presentation = Floating && not in_resize then Window.fit_to_output ctx window
;;

let handle_set_tags _ctx window (arg : Tag.Arg.t) =
  let set_tags s = Window.set_tags window s in
  match window.output, arg with
  | Some o, _ -> Output.resolve_tag_arg arg o |> set_tags
  | None, Concrete s -> set_tags s
  | None, Occupied -> ()
;;

let rec handle ctx window (request : Window.Request.t) =
  match request with
  | Move r -> handle_move ctx r.seat window
  | Move_to { x; y } ->
    Placement.move_window_to ~x ~y ctx window
    |> Result.iter_error @@ fun e -> Logs.warn @@ fun m -> m "%s" e
  | Resize r -> handle_resize ctx r.seat window r.edges
  | Resize_to { w; h } ->
    Placement.resize_window_to ~width:w ~height:h ctx window
    |> Result.iter_error @@ fun e -> Logs.warn @@ fun m -> m "%s" e
  | Maximize -> Placement.maximize ctx window
  | Unmaximize -> Placement.unmaximize ctx window
  | Fake_fullscreen -> Window.fake_fullscreen ctx window
  | Exit_fake_fullscreen -> Window.exit_fake_fullscreen ctx window
  | Fullscreen r -> Placement.fullscreen ctx r.output window handle
  | Exit_fullscreen -> Placement.exit_fullscreen ctx window
  | Dimensions d -> handle_set_dimensions ctx window d.width d.height
  | Set_tags arg -> handle_set_tags ctx window arg
  | Send_to_output_name { name; policy } ->
    Placement.send_window_to_name ctx window name policy
    |> Result.iter_error @@ fun e -> Logs.warn @@ fun m -> m "%s" e
  | Float -> Window.float ctx window
  | Tile -> Window.tile window
;;

let toggle_maximize ctx seat =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w ->
    (match w.presentation with
     | Maximized _ ->
       handle ctx w Unmaximize;
       Ok None
     | Tiled | Floating ->
       handle ctx w Maximize;
       Ok None
     | Fullscreen _ -> Error "cannot toggle maximization while window is fullscreen")
;;

let toggle_fake_fullscreen ctx seat =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w ->
    (match w.presentation with
     | Fullscreen _ ->
       Error "cannot toggle fake fullscreen when window is actually fullscreen"
     | _ ->
       (if w.is_fake_fullscreen then Exit_fake_fullscreen else Fake_fullscreen)
       |> handle ctx w;
       Ok None)
;;

let toggle_fullscreen ctx seat =
  match Seat.focused_window seat with
  | None -> Error Messages.no_focused_window
  | Some w ->
    (match w.presentation with
     | Fullscreen _ ->
       handle ctx w Exit_fullscreen;
       Ok None
     | _ when Option.is_none w.output -> Error Messages.window_missing_output
     | _ ->
       handle ctx w @@ Fullscreen { output = w.output };
       Ok None)
;;

let move_interactive ctx (seat : Seat.t) =
  match seat.op, seat.hovered with
  | Some _, _ -> Error "cannot begin move during an active operation"
  | None, None -> Error "no hovered window"
  | None, Some w when Window.is_fullscreen w -> Error "cannot move a fullscreen window"
  | None, Some w ->
    handle ctx w @@ Move { seat };
    Ok None
;;

let resize_interactive ctx (seat : Seat.t) =
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
    handle ctx w (Resize { seat; edges = Int32.logor horiz vert });
    Ok None
;;
