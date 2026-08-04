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
  | Focus_name { name; warp } -> Focus.output_name ?warp wm seat name
  | Toggle_overview -> Arrange.toggle_overview wm seat
  | Cycle_overview { dir; until_release } ->
    Arrange.cycle_overview wm seat dir ~until_release
  | Column_width delta -> Column.set_width seat delta ~global:true
  | Swap (Tags { target; policy; follow }) ->
    Placement.swap_outputs wm seat ~target ~policy ~follow `Tags
  | Swap (All { target; policy; follow }) ->
    Placement.swap_outputs wm seat ~target ~policy ~follow `All
  | Swap (Visible { target; policy; follow }) ->
    Placement.swap_outputs wm seat ~target ~policy ~follow `Visible
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
  | Close -> Placement.close_focused seat
  | Focus_logical { dir; warp } -> Focus.window_logical ?warp wm seat dir
  | Focus_spatial { dir; warp } -> Focus.window_spatial ?warp wm seat dir
  | Focus_match { wmatch; cycle; warp } -> Focus.window_match ?warp ~cycle wm seat wmatch
  | Tag { tags; follow } -> Tags.tag_window wm seat tags ~follow
  | Tag_shift { dir; follow } -> Tags.tag_shift_window wm seat dir ~follow
  | Tag_shift_occupied { dir; follow } ->
    Tags.tag_shift_window_occupied wm seat dir ~follow
  | Tag_match { wmatch; tags } -> Tags.tag_window_match wm seat wmatch tags
  | Move_drag -> Window_request.move_interactive wm seat
  | Move_to { x; y } -> Placement.move_to ~x ~y seat
  | Move_spatial { dir; by } -> Placement.move_spatial seat dir by
  | Resize_drag -> Window_request.resize_interactive wm seat
  | Resize_to { w; h } -> Placement.resize_to ~width:w ~height:h seat
  | Resize_spatial { dir; by } -> Placement.resize_spatial seat dir by
  | Send_logical { dir; policy; follow } ->
    Placement.send_to_logical wm seat dir policy ~follow
  | Send_spatial { dir; policy; follow } ->
    Placement.send_to_spatial wm seat dir policy ~follow
  | Send_name { name; policy; follow } ->
    Placement.send_to_name wm seat name policy ~follow
  | Shift dir -> Stacking.shift seat dir
  | Toggle_tag arg -> Tags.toggle_window_tags seat arg
  | Toggle_floating -> Placement.toggle_floating seat
  | Toggle_maximize -> Window_request.toggle_maximize wm seat
  | Toggle_fullscreen -> Window_request.toggle_fullscreen wm seat
  | Toggle_fake_fullscreen -> Window_request.toggle_fake_fullscreen wm seat
  | Zoom { warp } -> Placement.zoom ?warp wm seat
  | Column_consume -> Column.consume seat
  | Column_release -> Column.release seat
  | Column_move dir -> Column.move seat dir
  | Column_width delta -> Column.set_width seat delta ~global:false
  | Column_width_default -> Column.default_width seat
  | Column_width_cycle -> Column.cycle_width seat
  | Rule_add rule -> Window_rules.add wm rule
  | Rule_remove index -> Window_rules.remove wm index
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
    | exn -> Error (Printexc.to_string exn)
  in
  match result, reply with
  | Ok _, None -> ()
  | Error msg, None -> Logs.debug @@ fun m -> m "%s" msg
  | _, Some u -> Eio.Promise.resolve u result
;;
