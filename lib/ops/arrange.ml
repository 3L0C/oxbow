open! Ocdwm_core
open! Ocdwm_state

let with_focused_output (seat : Seat.t) f =
  match seat.output with
  | None -> Error Messages.seat_missing_output
  | Some o -> f o
;;

let set_mfact seat delta =
  with_focused_output seat
  @@ fun o ->
  Output.set_mfact o delta;
  Ok None
;;

let set_nmaster seat delta =
  with_focused_output seat
  @@ fun o ->
  Output.set_nmaster o delta;
  Ok None
;;

let set_gaps_inner seat delta =
  with_focused_output seat
  @@ fun o ->
  Output.set_gaps_inner o delta;
  Ok None
;;

let set_gaps_outer seat delta =
  with_focused_output seat
  @@ fun o ->
  Output.set_gaps_outer o delta;
  Ok None
;;

let set_stack seat kind ~global =
  with_focused_output seat
  @@ fun o ->
  Output.set_stack o kind ~global;
  Ok None
;;

let set_scroll_policy (wm : Wm.t) seat policy ~global =
  with_focused_output seat
  @@ fun o ->
  if global
  then List.iter (fun o' -> Output.set_scroll_policy o' policy ~global) wm.outputs
  else Output.set_scroll_policy o policy ~global;
  Ok None
;;

let set_default_width (wm : Wm.t) seat delta ~global =
  with_focused_output seat
  @@ fun o ->
  if global
  then List.iter (fun o' -> Output.set_default_width o' delta ~global) wm.outputs
  else Output.set_default_width o delta ~global;
  Ok None
;;

let set_orientation seat dir ~global =
  with_focused_output seat
  @@ fun o ->
  Output.set_orientation o dir ~global;
  Ok None
;;

let enter_overview ctx (output : Output.t) =
  if not output.overview
  then (
    List.iter (fun w -> Window_request.handle ctx w Exit_fullscreen) output.wm_stack;
    Output.set_overview output true)
;;

let exit_overview ctx (output : Output.t) =
  if output.overview
  then (
    Output.set_overview output false;
    (match Output.focused_window output with
     | Some w -> Output.switch_tags ~tags:w.tags output
     | None -> ());
    List.iter
      (fun (w : Window.t) ->
         match w.presentation with
         | Fullscreen _ | Tiled -> ()
         | Floating -> Window.restore_or_seed_float ctx w
         | Maximized { restore } -> Window.maximize ~restore ctx w)
      output.wm_stack;
    Dirty.mark_output output)
;;

let toggle_overview ctx seat =
  with_focused_output seat
  @@ fun o ->
  if o.overview then exit_overview ctx o else enter_overview ctx o;
  Ok None
;;

let set_layout ctx seat (l : Layout.t) ~global =
  with_focused_output seat
  @@ fun o ->
  let current = Output.current_layout o in
  if current = l
  then Ok None
  else (
    (match current, l with
     | (Tiling | Scrolling), Floating ->
       Output.tiled_windows o |> List.iter (Window.restore_or_seed_float ctx)
     | Floating, (Tiling | Scrolling) ->
       Output.tiled_windows o |> List.iter Window.remember_float
     | _ -> ());
    Output.set_layout o l ~global;
    Ok None)
;;

let select_scheme ctx (seat : Seat.t) scheme ~global =
  with_focused_output seat
  @@ fun o ->
  match set_layout ctx seat Tiling ~global with
  | Error _ as e -> e
  | Ok _ ->
    Output.set_scheme o scheme ~global;
    Ok None
;;

let cycle_layout ctx (seat : Seat.t) dir =
  with_focused_output seat
  @@ fun o ->
  let layout = Layout.cycle (Output.current_layout o) dir in
  set_layout ctx seat layout ~global:false
;;

let cycle_scheme ctx (seat : Seat.t) dir =
  with_focused_output seat
  @@ fun o ->
  match set_layout ctx seat Tiling ~global:false with
  | Error _ as e -> e
  | Ok _ ->
    Scheme.cycle (Output.current_scheme o) dir |> Output.set_scheme ~global:false o;
    Ok None
;;

let retile ctx (output : Output.t) =
  if output.overview
  then Overview.arrange ctx output
  else (
    match Output.current_layout output with
    | Tiling -> Tiling.arrange ctx output
    | Scrolling -> Scrolling.arrange ctx output
    | Floating ->
      ()
      (* NOTE: no call to Floating.arrange as floating windows don't need to be
         rearranged. The floating action happens above in the state trasition of
         set_layout and manage_window for new windows. *))
;;
