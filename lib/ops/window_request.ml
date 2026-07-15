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
    River.Window_management.River_window_v1.inform_unmaximized window.obj;
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
    River.Window_management.River_window_v1.inform_unmaximized window.obj;
    resize ()
  | Floating -> resize ()
;;

let handle_set_dimensions ctx window w h =
  let wm = Ctx.wm ctx in
  Window.set_geom ctx window { window.geom with w; h };
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

let handle_set_tags ctx window (arg : Tag.Arg.t) =
  let set_tags s = Window.set_tags window s in
  match window.output, arg with
  | Some o, _ -> Output.resolve_tag_arg arg o |> set_tags
  | None, Concrete s -> set_tags s
  | None, Occupied -> ()
;;

let rec handle ctx window (request : Window.Request.t) =
  match request with
  | Move r -> handle_move ctx r.seat window
  | Resize r -> handle_resize ctx r.seat window r.edges
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
    let () =
      match w.presentation with
      | Fullscreen _ -> handle ctx w Exit_fullscreen
      | _ -> handle ctx w @@ Fullscreen { output = w.output }
    in
    Ok None
;;

let move_interactive ctx (seat : Seat.t) =
  match seat.op, seat.hovered with
  | None, Some window ->
    handle ctx window @@ Move { seat };
    Ok None
  | _ -> Error "cannot begin move during an active operation"
;;

let resize_interactive ctx (seat : Seat.t) =
  match seat.op, seat.hovered with
  | None, Some window ->
    handle
      ctx
      window
      (Resize
         { seat
         ; edges =
             Int32.logor
               River.Window_management.River_window_v1.Edges.right
               River.Window_management.River_window_v1.Edges.bottom
         });
    Ok None
  | _ -> Error "cannot begin resize during an active operation"
;;
