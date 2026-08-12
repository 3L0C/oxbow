open! Oxbow_core
open! Oxbow_state
open! Result.Syntax

let outputs_of_scope wm seat (scope : Scope.t) =
  match scope with
  | Focused -> With.focused_output seat @@ fun o -> Ok [ o ]
  | Output name -> With.named_output wm ~name @@ fun o -> Ok [ o ]
  | All -> Ok wm.outputs
;;

let apply_scoped wm seat scope ~f =
  let+ outputs = outputs_of_scope wm seat scope in
  let apply o =
    match scope with
    | Focused -> f (Output.to_tag_data o)
    | Output _ | All -> Tag.Set.iter (fun s -> Output.tag_data o s |> f) Tag.Set.all
  in
  List.iter apply outputs;
  if scope = All then f wm.config.default_tag_config;
  Schedule.manage ();
  None
;;

let set_tiling_scheme wm seat scheme scope =
  apply_scoped wm seat scope ~f:(Output.apply_scheme ~scheme)
;;

let set_mfact wm seat delta scope =
  apply_scoped wm seat scope ~f:(Output.apply_mfact ~delta)
;;

let set_nmaster wm seat delta scope =
  apply_scoped wm seat scope ~f:(Output.apply_nmaster ~delta)
;;

let set_gaps_inner wm seat delta scope =
  apply_scoped wm seat scope ~f:(Output.apply_gaps_inner ~delta)
;;

let set_gaps_outer wm seat delta scope =
  apply_scoped wm seat scope ~f:(Output.apply_gaps_outer ~delta)
;;

let set_gaps_overview wm seat delta scope =
  let+ outputs = outputs_of_scope wm seat scope in
  List.iter (Output.set_gaps_overview ~delta) outputs;
  Schedule.manage ();
  None
;;

let set_scrolling_alignment wm seat align scope =
  apply_scoped wm seat scope ~f:(Output.apply_scrolling_align ~align)
;;

let set_default_width wm seat delta scope =
  apply_scoped wm seat scope ~f:(Output.apply_default_width ~delta)
;;

let set_scrolling_orientation wm seat dir scope =
  apply_scoped wm seat scope ~f:(Output.apply_scrolling_orientation ~dir)
;;

let set_tiling_orientation wm seat dir scope =
  apply_scoped wm seat scope ~f:(Output.apply_tiling_orientation ~dir)
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
  let* b =
    match until_release with
    | None -> Ok None
    | Some s -> Bind.parse_modifiers s |> Result.map Option.some
  in
  With.focused_window seat
  @@ fun o head ->
  let target =
    let visible = List.filter Window.tag_visible o.focus_stack in
    match dir with
    | Next -> Ring.next_or_first head visible
    | Prev -> Ring.prev_or_last head visible
  in
  if not o.overview.enabled then enter_overview wm o;
  Option.iter Stacking.focus_window target;
  Option.iter (fun m -> Seat.set_overview_watch seat m) b;
  Ok None
;;

let set_layout wm seat (layout : Layout.t) scope =
  let* outputs = outputs_of_scope wm seat scope in
  let target_floats = layout = Floating in
  let fixup (o : Output.t) =
    let tags_written =
      match scope with
      | Focused ->
        Tag.Set.first o.tags.selected |> Option.value ~default:(Tag.Set.singleton 1)
      | Output _ | All -> Tag.Set.all
    in
    let crossed =
      Tag.Set.to_list tags_written
      |> List.filter (fun s ->
        let td = Output.tag_data o s in
        td.layout = Floating <> target_floats)
    in
    let windows =
      List.filter
        (fun w ->
           Window.is_tiled w && List.exists (fun s -> Window.on_tags w ~tags:s) crossed)
        o.wm_stack
    in
    let fix =
      if target_floats then Window.restore_or_seed_float else Window.remember_float
    in
    List.iter fix windows
  in
  List.iter fixup outputs;
  apply_scoped wm seat scope ~f:(Output.apply_layout ~layout)
;;

let select_tiling_scheme wm seat scheme scope =
  set_layout wm seat Tiling scope
  |> Result.map (fun _ -> apply_scoped wm seat scope ~f:(Output.apply_scheme ~scheme))
  |> Result.join
;;

let select_scrolling_alignment wm seat align scope =
  set_layout wm seat Scrolling scope
  |> Result.map (fun _ ->
    apply_scoped wm seat scope ~f:(Output.apply_scrolling_align ~align))
  |> Result.join
;;

let cycle_scheme wm seat dir =
  With.focused_output seat
  @@ fun o ->
  let scheme = Scheme.cycle (Output.current_scheme o) dir in
  select_tiling_scheme wm seat scheme Focused
;;

let cycle_layout wm seat dir =
  With.focused_output seat
  @@ fun o ->
  let layout = Layout.cycle (Output.current_layout o) dir in
  set_layout wm seat layout Focused
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
