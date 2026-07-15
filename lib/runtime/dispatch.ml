open! Ppx_yojson_conv_lib.Yojson_conv
open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_ops

let handle_action ctx seat (action : Action.t) =
  let wm = Ctx.wm ctx in
  match action with
  | Spawn cmd ->
    Spawn.spawn cmd;
    Ok None
  | Exit_session ->
    Lifecycle.request_exit wm;
    Ok None
  | Close_wm ->
    Lifecycle.request_close wm;
    Ok None
  | Close_focused -> Placement.close_focused seat
  | Toggle_floating -> Placement.toggle_floating ctx seat
  | Toggle_maximize -> Window_request.toggle_maximize ctx seat
  | Toggle_fake_fullscreen -> Window_request.toggle_fake_fullscreen ctx seat
  | Toggle_fullscreen -> Window_request.toggle_fullscreen ctx seat
  | Move_interactive -> Window_request.move_interactive ctx seat
  | Resize_interactive -> Window_request.resize_interactive ctx seat
  | Move_to { x; y } -> Placement.move_to ctx seat x y
  | Move_spatial { dir; by } -> Placement.move_spatial ctx seat dir by
  | Resize_to { w = width; h = height } -> Placement.resize_to ctx seat width height
  | Resize_spatial { dir; by } -> Placement.resize_spatial ctx seat dir by
  | Send_to_output_logical { dir; policy } ->
    Placement.send_to_logical ctx seat dir policy
  | Send_to_output_spatial { dir; policy } ->
    Placement.send_to_spatial ctx seat dir policy
  | Send_to_output_name { name; policy } -> Placement.send_to_name ctx seat name policy
  | Focus_window_logical dir ->
    Focus.window_logical ctx seat dir;
    Ok None
  | Focus_window_spatial dir ->
    Focus.window_spatial ctx seat dir;
    Ok None
  | Focus_window_query q ->
    Focus.window_query ctx seat q;
    Ok None
  | Focus_output_logical dir ->
    Focus.output_logical ctx seat dir;
    Ok None
  | Focus_output_spatial dir ->
    Focus.output_spatial ctx seat dir;
    Ok None
  | Focus_output_name name ->
    Focus.output_name ctx seat name;
    Ok None
  | Shift dir -> Stacking.shift seat dir
  | Zoom ->
    Placement.zoom ctx seat;
    Ok None
  | Tag_view arg -> Tags.view seat arg
  | Tag_toggle_view tags -> Tags.toggle_view seat tags
  | Tag_view_previous -> Tags.view_previous seat
  | Tag_view_cycle dir -> Tags.view_cycle seat dir
  | Tag_view_cycle_occupied dir -> Tags.view_cycle_occupied seat dir
  | Window_tag arg -> Tags.tag_window seat arg
  | Window_toggle_tag tags -> Tags.toggle_window_tags seat tags
  | Layout_set name -> Placement.select_layout ctx seat name
  | Layout_cycle dir -> Placement.cycle_layout ctx seat dir
  | Set_mfact delta -> Arrange.set_mfact seat delta
  | Set_nmaster delta -> Arrange.set_nmaster seat delta
  | Set_gaps_inner delta -> Arrange.set_gaps_inner seat delta
  | Set_gaps_outer delta -> Arrange.set_gaps_outer seat delta
  | Set_stack kind -> Arrange.set_stack seat kind
  | Set_focus_follows_pointer b ->
    Config.set_focus_follows_pointer wm b;
    Ok None
  | Toggle_focus_follows_pointer ->
    Config.set_focus_follows_pointer wm @@ not wm.config.focus_follows_pointer;
    Ok None
  | Set_keyboard_repeat { rate; delay } ->
    Keyboard.set_repeat_info wm ~rate ~delay;
    Ok None
  | Set_keyboard_layout_file path ->
    (match Keyboard.set_layout_file wm ~path with
     | Ok () -> Ok None
     | Error msg -> Error msg)
  | Set_warp_on_focus b ->
    Config.set_warp_on_focus wm b;
    Ok None
  | Toggle_warp_on_focus ->
    Config.set_warp_on_focus wm @@ not wm.config.warp_on_focus;
    Ok None
  | Set_cursor_theme { name; size } ->
    Cursor.set_theme wm seat name @@ Int32.of_int size;
    Ok None
  | Set_border_width width ->
    Config.set_border_width wm width;
    Ok None
  | Set_border_color { which; color } ->
    Config.set_border_color wm which color;
    Ok None
  | Add_rule rule ->
    if List.exists (Rule.equal rule) wm.config.rules
    then Error "duplicate rule"
    else (
      Config.add_rule wm rule;
      Ok None)
  | Remove_rule rule ->
    if not @@ List.exists (Rule.equal rule) wm.config.rules
    then Error "no such rule"
    else (
      Config.remove_rule wm rule;
      Ok None)
;;

let handle_setting ctx seat setting = Bind.handle ctx seat setting

let handle_query (wm : Wm.t) (query : Query.t) =
  match query with
  | Rules -> Ok (Some ([%yojson_of: Rule.t list] wm.config.rules))
;;

let handle ctx seat ({ body; reply } : Pending_request.t) =
  let result =
    try
      match body with
      | Trigger action -> handle_action ctx seat action
      | Setting setting -> handle_setting ctx seat setting
      | Query query -> handle_query (Ctx.wm ctx) query
    with
    | Exceptions.Finished -> raise Exceptions.Finished
    | exn -> Error (Printexc.to_string exn)
  in
  match result, reply with
  | Ok _, None -> ()
  | Error msg, None -> Logs.err @@ fun m -> m "%s" msg
  | _, Some u -> Eio.Promise.resolve u result
;;
