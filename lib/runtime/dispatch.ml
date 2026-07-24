open! Ocdwm_core
open! Ocdwm_ipc
open! Ocdwm_state
open! Ocdwm_ops
open! Ocdwm_layout

let handle_border ctx seat (cmd : Command.Border.t) =
  let wm = Ctx.wm ctx in
  match cmd with
  | Width width ->
    Config.set_border_width wm width;
    Ok None
  | Color { which; color } ->
    Config.set_border_color wm which color;
    Ok None
;;

let handle_gaps ctx seat (cmd : Command.Gaps.t) =
  match cmd with
  | Inner { delta; global } -> Arrange.set_gaps_inner seat delta ~global
  | Outer { delta; global } -> Arrange.set_gaps_outer seat delta ~global
;;

let handle_input ctx seat (cmd : Command.Input.t) =
  match cmd with
  | Cursor c -> Cursor.handle ctx seat c
  | Keyboard c -> Keyboard.handle ctx seat c
  | Pointer c -> Pointer.handle ctx seat c
;;

let handle_keymap ctx seat (cmd : Command.Keymap.t) =
  match cmd with
  | Mode c -> Modes.handle ctx seat c
;;

let handle_layout = Layouts.handle

let handle_output ctx seat (cmd : Command.Output.t) =
  match cmd with
  | Focus_logical { dir; warp } -> Focus.output_logical ?warp ctx seat dir
  | Focus_spatial { dir; warp } -> Focus.output_spatial ?warp ctx seat dir
  | Focus_name { name; warp } -> Focus.output_name ?warp ctx seat name
  | Toggle_overview -> Arrange.toggle_overview ctx seat
  | Column_width delta -> Column.set_width seat delta ~global:true
  | Swap (Tags { target; policy }) ->
    Placement.swap_outputs ctx seat ~target ~policy `Tags
  | Swap (All { target; policy }) -> Placement.swap_outputs ctx seat ~target ~policy `All
  | Swap (Visible { target; policy }) ->
    Placement.swap_outputs ctx seat ~target ~policy `Visible
;;

let handle_rule = Rules.handle

let handle_session ctx seat (cmd : Command.Session.t) =
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

let handle_window ctx seat (cmd : Command.Window.t) =
  match cmd with
  | Close -> Placement.close_focused seat
  | Focus_logical { dir; warp } -> Focus.window_logical ?warp ctx seat dir
  | Focus_spatial { dir; warp } -> Focus.window_spatial ?warp ctx seat dir
  | Focus_query { query; cycle; warp } -> Focus.window_query ?warp ~cycle ctx seat query
  | Tag_query { query; tags } -> Tags.tag_window_query ctx query tags
  | Tag_shift dir -> Tags.tag_shift_window seat dir
  | Tag_shift_occupied dir -> Tags.tag_shift_window_occupied seat dir
  | Move_drag -> Window_request.move_interactive ctx seat
  | Move_to { x; y } -> Placement.move_to ~x ~y ctx seat
  | Move_spatial { dir; by } -> Placement.move_spatial ctx seat dir by
  | Resize_drag -> Window_request.resize_interactive ctx seat
  | Resize_to { w; h } -> Placement.resize_to ~width:w ~height:h ctx seat
  | Resize_spatial { dir; by } -> Placement.resize_spatial ctx seat dir by
  | Send_logical { dir; policy } -> Placement.send_to_logical ctx seat dir policy
  | Send_spatial { dir; policy } -> Placement.send_to_spatial ctx seat dir policy
  | Send_name { name; policy } -> Placement.send_to_name ctx seat name policy
  | Shift dir -> Stacking.shift seat dir
  | Tag arg -> Tags.tag_window seat arg
  | Toggle_tag arg -> Tags.toggle_window_tags seat arg
  | Toggle_floating -> Placement.toggle_floating ctx seat
  | Toggle_maximize -> Window_request.toggle_maximize ctx seat
  | Toggle_fullscreen -> Window_request.toggle_fullscreen ctx seat
  | Toggle_fake_fullscreen -> Window_request.toggle_fake_fullscreen ctx seat
  | Zoom { warp } -> Placement.zoom ?warp ctx seat
  | Column_consume -> Column.consume seat
  | Column_release -> Column.release seat
  | Column_move dir -> Column.move seat dir
  | Column_width delta -> Column.set_width seat delta ~global:false
  | Column_width_default -> Column.default_width seat
  | Column_width_cycle -> Column.cycle_width seat
;;

let handle_wm ctx seat (cmd : Command.Wm.t) =
  let wm = Ctx.wm ctx in
  let () =
    match cmd with
    | Close -> Lifecycle.request_close wm
  in
  Ok None
;;

let handle_command ctx seat (cmd : Command.t) =
  match cmd with
  | Border c -> handle_border ctx seat c
  | Exec argv -> Execute.exec argv
  | Gaps c -> handle_gaps ctx seat c
  | Input c -> handle_input ctx seat c
  | Keymap c -> handle_keymap ctx seat c
  | Layout c -> handle_layout ctx seat c
  | Output c -> handle_output ctx seat c
  | Rule c -> handle_rule ctx seat c
  | Session c -> handle_session ctx seat c
  | Spawn cmd -> Execute.spawn cmd
  | Tag c -> handle_tag seat c
  | Window c -> handle_window ctx seat c
  | Wm c -> handle_wm ctx seat c
;;

let handle_keymap = Bind.handle
let handle_query = Queries.handle

let handle ctx seat ({ body; reply } : Pending_request.t) =
  let result =
    try
      match body with
      | Command c -> handle_command ctx seat c
      | Keymap keymap -> handle_keymap ctx seat keymap
      | Query query -> handle_query (Ctx.wm ctx) seat query
      | Subscribe _ -> Error "subscribe handled at the connection layer"
    with
    | Exceptions.Finished -> raise Exceptions.Finished
    | exn -> Error (Printexc.to_string exn)
  in
  match result, reply with
  | Ok _, None -> ()
  | Error msg, None -> Logs.debug @@ fun m -> m "%s" msg
  | _, Some u -> Eio.Promise.resolve u result
;;
