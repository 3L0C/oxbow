open! Ppx_yojson_conv_lib.Yojson_conv
open! Ocdwm_core
open! Ocdwm_ipc
open! Ocdwm_state
open! Ocdwm_ops

let handle_window ctx seat (cmd : Command.Window.t) =
  match cmd with
  | Close -> Placement.close_focused seat
  | Focus_logical dir -> Focus.window_logical ctx seat dir
  | Focus_spatial dir -> Focus.window_spatial ctx seat dir
  | Focus_query q -> Focus.window_query ctx seat q
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
  | Zoom -> Placement.zoom ctx seat
;;

let handle_tag seat (cmd : Command.Tag.t) =
  match cmd with
  | View arg -> Tags.view seat arg
  | Toggle_view tags -> Tags.toggle_view seat tags
  | View_previous -> Tags.view_previous seat
  | View_cycle dir -> Tags.view_cycle seat dir
  | View_cycle_occupied dir -> Tags.view_cycle_occupied seat dir
;;

let handle_layout ctx seat (cmd : Command.Layout.t) =
  match cmd with
  | Cycle dir -> Placement.cycle_layout ctx seat dir
;;

let handle_output ctx seat (cmd : Command.Output.t) =
  match cmd with
  | Focus_logical dir -> Focus.output_logical ctx seat dir
  | Focus_spatial dir -> Focus.output_spatial ctx seat dir
  | Focus_name name -> Focus.output_name ctx seat name
;;

let handle_set ctx seat (cmd : Command.Set.t) =
  let wm = Ctx.wm ctx in
  match cmd with
  | Layout name -> Placement.select_layout ctx seat name
  | Mfact delta -> Arrange.set_mfact seat delta
  | Nmaster delta -> Arrange.set_nmaster seat delta
  | Gaps_inner delta -> Arrange.set_gaps_inner seat delta
  | Gaps_outer delta -> Arrange.set_gaps_outer seat delta
  | Stack kind -> Arrange.set_stack seat kind
  | Focus_follows_pointer b ->
    Config.set_focus_follows_pointer wm b;
    Ok None
  | Toggle_focus_follows_pointer ->
    Config.set_focus_follows_pointer wm @@ not wm.config.focus_follows_pointer;
    Ok None
  | Keyboard_repeat { rate; delay } ->
    Config.set_key_repeat ~rate ~delay wm;
    Ok None
  | Keyboard_layout_file path -> Keyboard.set_layout_file ~path wm
  | Pointer_warp b ->
    Config.set_warp_on_focus wm b;
    Ok None
  | Toggle_pointer_warp ->
    Config.set_warp_on_focus wm @@ not wm.config.warp_on_focus;
    Ok None
  | Cursor_theme { name; size } ->
    Cursor.set_theme wm seat name size;
    Ok None
  | Border_width width ->
    Config.set_border_width wm width;
    Ok None
  | Border_color { which; color } ->
    Config.set_border_color wm which color;
    Ok None
;;

let handle_rule ctx seat (cmd : Command.Rule.t) =
  let wm = Ctx.wm ctx in
  match cmd with
  | Add rule -> Rules.add wm rule
  | Remove rule -> Rules.remove wm rule
;;

let handle_session ctx seat (cmd : Command.Session.t) =
  let wm = Ctx.wm ctx in
  let () =
    match cmd with
    | Exit -> Lifecycle.request_exit wm
  in
  Ok None
;;

let handle_wm ctx seat (cmd : Command.Wm.t) =
  let wm = Ctx.wm ctx in
  let () =
    match cmd with
    | Close -> Lifecycle.request_close wm
  in
  Ok None
;;

let handle_execute (cmd : Command.Execute.t) =
  match cmd with
  | Spawn cmd -> Execute.spawn cmd
  | Exec argv -> Execute.exec argv
;;

let handle_command ctx seat (cmd : Command.t) =
  match cmd with
  | Window c -> handle_window ctx seat c
  | Tag c -> handle_tag seat c
  | Layout c -> handle_layout ctx seat c
  | Output c -> handle_output ctx seat c
  | Set c -> handle_set ctx seat c
  | Rule c -> handle_rule ctx seat c
  | Session c -> handle_session ctx seat c
  | Wm c -> handle_wm ctx seat c
  | Execute c -> handle_execute c
;;

let handle_keymap ctx seat keymap = Bind.handle ctx seat keymap

let handle_query (wm : Wm.t) (query : Query.t) =
  match query with
  | Rules -> Ok (Some ([%yojson_of: Rule.t list] wm.config.rules))
;;

let handle ctx seat ({ body; reply } : Pending_request.t) =
  let result =
    try
      match body with
      | Command c -> handle_command ctx seat c
      | Keymap keymap -> handle_keymap ctx seat keymap
      | Query query -> handle_query (Ctx.wm ctx) query
    with
    | Exceptions.Finished -> raise Exceptions.Finished
    | exn -> Error (Printexc.to_string exn)
  in
  match result, reply with
  | Ok _, None -> ()
  | Error msg, None -> Logs.debug @@ fun m -> m "%s" msg
  | _, Some u -> Eio.Promise.resolve u result
;;
