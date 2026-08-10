open! Oxbow_ipc
open! Oxbow_state
open! Oxbow_ops

let handle_border wm _seat (cmd : Command.Border.t) =
  match cmd with
  | Width width -> Config.set_border_width wm width
  | Color { which; color } ->
    Config.set_border_color wm which color;
    Ok None
;;

let handle_gaps ctx seat (cmd : Command.Gaps.t) =
  let wm = Ctx.wm ctx in
  match cmd with
  | Inner { delta; scope } -> Arrange.set_gaps_inner wm seat delta scope
  | Outer { delta; scope } -> Arrange.set_gaps_outer wm seat delta scope
  | Overview { delta; scope } -> Arrange.set_gaps_overview wm seat delta scope
;;

let handle_input ctx seat (cmd : Command.Input.t) =
  let wm = Ctx.wm ctx in
  match cmd with
  | Cursor c -> Cursor.handle wm seat c
  | Keyboard c -> Keyboard.handle ctx seat c
  | Pointer c -> Pointer.handle wm seat c
  | Rule_add rule -> Input_rules.add wm rule
  | Rule_remove index -> Input_rules.remove wm index
;;

let handle_keymap ctx seat (cmd : Command.Keymap.t) =
  match cmd with
  | Mode c -> Modes.handle ctx seat c
;;

let handle_layout = Layouts.handle

let handle_output wm seat (cmd : Command.Output.t) =
  match cmd with
  | Focus_logical { dir; warp } -> Focus.output_logical ?warp wm seat dir
  | Focus_spatial { dir; warp } -> Focus.output_spatial ?warp wm seat dir
  | Focus_match { target; warp } -> Focus.output_match ?warp wm seat target
  | Toggle_overview -> Arrange.toggle_overview wm seat
  | Cycle_overview { dir; until_release } ->
    Arrange.cycle_overview wm seat dir ~until_release
  | Column_width delta -> Column.set_width wm seat Focused delta ~global:true
  | Swap (Tags { target; policy; follow }) ->
    Placement.swap_outputs wm seat ~target ~policy ~follow `Tags
  | Swap (All { target; policy; follow }) ->
    Placement.swap_outputs wm seat ~target ~policy ~follow `All
  | Swap (Visible { target; policy; follow }) ->
    Placement.swap_outputs wm seat ~target ~policy ~follow `Visible
  | Label_add { label; target } -> Labels.output_add wm seat target label
  | Label_remove { label; target } -> Labels.output_remove wm seat target label
;;

let handle_session ctx _seat (cmd : Command.Session.t) =
  let wm = Ctx.wm ctx in
  let () =
    match cmd with
    | Exit -> Lifecycle.request_exit wm
  in
  Ok None
;;

let handle_tag seat (cmd : Command.Tag.t) =
  match cmd with
  | View arg -> Tags.view seat arg
  | Toggle_view tags -> Tags.toggle_view seat tags
  | View_previous -> Tags.view_previous seat
  | View_cycle dir -> Tags.view_cycle seat dir
  | View_cycle_occupied dir -> Tags.view_cycle_occupied seat dir
;;

let handle_window wm seat (cmd : Command.Window.t) =
  match cmd with
  | Close target -> Placement.close wm seat target
  | Focus_logical { dir; warp; target } -> Focus.window_logical ?warp wm seat target dir
  | Focus_spatial { dir; warp; target } -> Focus.window_spatial ?warp wm seat target dir
  | Focus_match { warp; target } -> Focus.window_match ?warp wm seat target
  | Tag { tags; follow; target } -> Tags.tag_window wm seat target ~tags ~follow
  | Tag_shift { dir; follow; target } -> Tags.tag_shift_window wm seat target dir ~follow
  | Tag_shift_occupied { dir; follow; target } ->
    Tags.tag_shift_window_occupied wm seat target dir ~follow
  | Move_drag -> Window_request.move_interactive wm seat
  | Move_to { x; y; target } -> Placement.move_to ~x ~y wm seat target
  | Move_spatial { dir; by; target } -> Placement.move_spatial wm seat target dir by
  | Resize_drag -> Window_request.resize_interactive wm seat
  | Resize_to { w; h; target } -> Placement.resize_to ~width:w ~height:h wm seat target
  | Resize_spatial { dir; by; target } -> Placement.resize_spatial wm seat target dir by
  | Send_logical { dir; policy; follow; target } ->
    Placement.send_to_logical wm seat target dir policy ~follow
  | Send_spatial { dir; policy; follow; target } ->
    Placement.send_to_spatial wm seat target dir policy ~follow
  | Send_name { name; policy; follow; target } ->
    Placement.send_to_name wm seat target name policy ~follow
  | Shift { dir; target } -> Stacking.shift wm seat target dir
  | Set_sticky { scope; target } -> Placement.set_sticky wm seat target scope
  | Toggle_sticky { toggle; target } -> Placement.toggle_sticky wm seat target toggle
  | Toggle_swallow target -> Swallow.toggle wm seat target
  | Toggle_tag { tags; target } -> Tags.toggle_window_tags wm seat target tags
  | Toggle_floating target -> Placement.toggle_floating wm seat target
  | Toggle_maximize target -> Window_request.toggle_maximize wm seat target
  | Toggle_fullscreen target -> Window_request.toggle_fullscreen wm seat target
  | Toggle_fake_fullscreen target -> Window_request.toggle_fake_fullscreen wm seat target
  | Zoom { warp; target } -> Placement.zoom ?warp wm seat target
  | Column_consume target -> Column.consume wm seat target
  | Column_release target -> Column.release wm seat target
  | Column_move { dir; target } -> Column.move wm seat target dir
  | Column_width { delta; target } -> Column.set_width wm seat target delta ~global:false
  | Column_width_default target -> Column.default_width wm seat target
  | Column_width_cycle target -> Column.cycle_width wm seat target
  | Rule_add rule -> Window_rules.add wm rule
  | Rule_remove index -> Window_rules.remove wm index
  | Label_add { label; target } -> Labels.window_add wm seat target label
  | Label_remove { label; target } -> Labels.window_remove wm seat target label
  | Spawn_position position ->
    Config.set_spawn_position wm position;
    Ok None
  | Spawn_focus b ->
    Config.set_spawn_focus wm b;
    Ok None
  | Drag_retile b ->
    Config.set_drag_retile wm b;
    Ok None
;;

let handle_wm ctx _seat (cmd : Command.Wm.t) =
  let wm = Ctx.wm ctx in
  let () =
    match cmd with
    | Close -> Lifecycle.request_close wm
  in
  Ok None
;;

let handle_command ctx seat (cmd : Command.t) =
  let wm = Ctx.wm ctx in
  match cmd with
  | Border c -> handle_border wm seat c
  | Exec argv -> Execute.exec argv
  | Gaps c -> handle_gaps ctx seat c
  | Input c -> handle_input ctx seat c
  | Keymap c -> handle_keymap wm seat c
  | Layout c -> handle_layout wm seat c
  | Output c -> handle_output wm seat c
  | Session c -> handle_session ctx seat c
  | Spawn cmd -> Execute.spawn cmd
  | Tag c -> handle_tag seat c
  | Window c -> handle_window wm seat c
  | Wm c -> handle_wm ctx seat c
;;

let handle_keymap = Bind.handle
let handle_query = Queries.handle

let handle ctx seat ({ body; reply } : Pending_request.t) =
  let wm = Ctx.wm ctx in
  let result =
    try
      match body with
      | Command c -> handle_command ctx seat c
      | Keymap keymap -> handle_keymap wm seat keymap
      | Query query -> handle_query (Ctx.wm ctx) seat query
      | Subscribe _ -> Error "subscribe handled at the connection layer"
    with
    | exn ->
      let estr = Printexc.to_string exn in
      Logs.err (fun m -> m "dispatch raised: %s@.%s" estr (Printexc.get_backtrace ()));
      Error estr
  in
  match result, reply with
  | Ok _, None -> ()
  | Error msg, None -> Logs.debug @@ fun m -> m "%s" msg
  | _, Some u -> Eio.Promise.resolve u result
;;
