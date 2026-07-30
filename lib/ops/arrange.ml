open! Ocdwm_core
open! Ocdwm_state

let set_mfact seat delta ~global =
  With.focused_output seat
  @@ fun o ->
  Output.set_mfact o delta ~global;
  Ok None
;;

let set_nmaster seat delta ~global =
  With.focused_output seat
  @@ fun o ->
  Output.set_nmaster o delta ~global;
  Ok None
;;

let set_gaps_inner seat delta ~global =
  With.focused_output seat
  @@ fun o ->
  Output.set_gaps_inner o delta ~global;
  Ok None
;;

let set_gaps_outer seat delta ~global =
  With.focused_output seat
  @@ fun o ->
  Output.set_gaps_outer o delta ~global;
  Ok None
;;

let set_gaps_overview seat delta =
  With.focused_output seat
  @@ fun o ->
  Output.set_gaps_overview o ~delta;
  Ok None
;;

let set_scroll_policy (wm : Wm.t) seat policy ~global =
  With.focused_output seat
  @@ fun o ->
  if global
  then List.iter (fun o' -> Output.set_scroll_policy o' policy ~global) wm.outputs
  else Output.set_scroll_policy o policy ~global;
  Ok None
;;

let set_default_width (wm : Wm.t) seat delta ~global =
  With.focused_output seat
  @@ fun o ->
  if global
  then (
    List.iter (fun o' -> Output.set_default_width o' delta ~global) wm.outputs;
    Config.set_default_width wm.config.default_tag_config ~delta)
  else Output.set_default_width o delta ~global;
  Ok None
;;

let set_orientation seat dir ~global =
  With.focused_output seat
  @@ fun o ->
  Output.set_orientation o dir ~global;
  Ok None
;;

let enter_overview wm (output : Output.t) =
  if not output.overview.enabled
  then (
    List.iter (fun w -> Window_request.handle wm w Exit_fullscreen) output.wm_stack;
    Output.enter_overview output)
;;

let exit_overview (output : Output.t) =
  if output.overview.enabled
  then (
    let head = output.overview.head in
    Output.exit_overview output;
    (match head with
     | Some w -> Stacking.focus_window w
     | None -> ());
    List.iter
      (fun (w : Window.t) ->
         match w.presentation with
         | Fullscreen _ | Tiled -> ()
         | Floating -> Window.restore_or_seed_float w
         | Maximized { restore } -> Window.maximize ~restore w)
      output.wm_stack;
    Schedule.manage ())
;;

let toggle_overview wm seat =
  With.focused_output seat
  @@ fun o ->
  if o.overview.enabled then exit_overview o else enter_overview wm o;
  Ok None
;;

let cycle_overview wm (seat : Seat.t) (dir : Direction.Logical.t) ~until_release =
  let mods =
    match until_release with
    | None -> Ok None
    | Some s ->
      String.split_on_char '+' s
      |> List.map Bind.parse_modifier
      |> List.fold_left
           (fun acc b -> Result.bind acc (fun a -> Result.map (Int32.logor a) b))
           (Ok 0l)
      |> Result.map Option.some
  in
  match mods with
  | Error _ as e -> e
  | Ok b ->
    With.focused_window seat
    @@ fun o head ->
    let target =
      match dir with
      | Next -> Ring.next_or_first head o.focus_stack
      | Prev -> Ring.prev_or_last head o.focus_stack
    in
    if not o.overview.enabled then enter_overview wm o;
    Option.iter Stacking.focus_window target;
    Option.iter (fun m -> Seat.set_overview_watch seat m) b;
    Ok None
;;

let set_layout seat (l : Layout.t) ~global =
  With.focused_output seat
  @@ fun o ->
  let current = Output.current_layout o in
  if current = l
  then Ok None
  else (
    (match current, l with
     | (Tiling | Scrolling), Floating ->
       Output.tiled_windows o |> List.iter Window.restore_or_seed_float
     | Floating, (Tiling | Scrolling) ->
       Output.tiled_windows o |> List.iter Window.remember_float
     | _ -> ());
    Output.set_layout o l ~global;
    Ok None)
;;

let select_scheme seat scheme ~global =
  With.focused_output seat
  @@ fun o ->
  match set_layout seat Tiling ~global with
  | Error _ as e -> e
  | Ok _ ->
    Output.set_scheme o scheme ~global;
    Ok None
;;

let cycle_scheme seat dir =
  With.focused_output seat
  @@ fun o ->
  match set_layout seat Tiling ~global:false with
  | Error _ as e -> e
  | Ok _ ->
    Output.cycle_scheme o dir ~global:false;
    Ok None
;;

let cycle_layout seat dir =
  With.focused_output seat
  @@ fun o ->
  let layout = Layout.cycle (Output.current_layout o) dir in
  set_layout seat layout ~global:false
;;

let retile wm (output : Output.t) =
  if output.overview.enabled
  then Overview.arrange wm output
  else (
    match Output.current_layout output with
    | Tiling -> Tiling.arrange wm output
    | Scrolling -> Scrolling.arrange wm output
    | Floating ->
      ()
      (* NOTE: no call to Floating.arrange as floating windows don't need to be
         rearranged. The floating action happens above in the state trasition of
         set_layout and manage_window for new windows. *))
;;
