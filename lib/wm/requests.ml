module Rwm = Ocdwm_protocol.River_window_management_v1_client
module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
open! Ocdwm_core

exception Dispatch_failed of string

let dispatch_failed s = raise (Dispatch_failed s)

let rec window_request
          (ctx : Ctx.manage Ctx.t)
          (window : Types.Window.t)
          (request : Types.Window_request.t)
  =
  let wm = Ctx.wm ctx in
  match request with
  | Req_move r ->
    let move () = Input.pointer_move ctx r.seat window in
    (match window.presentation with
     | P_fullscreen _ -> ()
     | P_tiled ->
       if not @@ Output.is_floating window.output
       then (
         window.presentation <- P_floating;
         Option.iter (Output.mark_dirty wm) window.output);
       move ()
     | P_maximized _ ->
       window.presentation <- P_floating;
       Rwm.River_window_v1.inform_unmaximized window.obj;
       move ()
     | P_floating -> move ())
  | Req_resize r ->
    let resize () = Input.pointer_resize ctx r.seat window r.edges in
    (match window.presentation with
     | P_fullscreen _ -> ()
     | P_tiled ->
       if not @@ Output.is_floating window.output
       then (
         window.presentation <- P_floating;
         Option.iter (Output.mark_dirty wm) window.output);
       resize ()
     | P_maximized _ ->
       window.presentation <- P_floating;
       Rwm.River_window_v1.inform_unmaximized window.obj;
       resize ()
     | P_floating -> resize ())
  | Req_maximize ->
    List.iter (Seat.op_end ctx) wm.seats;
    Window.maximize ctx window;
    Option.iter (Output.mark_dirty wm) window.output
  | Req_unmaximize ->
    Window.unmaximize ctx window;
    Option.iter (Output.mark_dirty wm) window.output
  | Req_fake_fullscreen -> Window.fake_fullscreen ctx window
  | Req_exit_fake_fullscreen -> Window.exit_fake_fullscreen ctx window
  | Req_fullscreen r ->
    let enter () =
      match r.output, window.output with
      | None, None -> ()
      | Some o, _ | None, Some o ->
        List.iter
          (fun w ->
             if Window.tag_visible w && Window.is_fullscreen w
             then window_request ctx w Req_exit_fullscreen)
          o.focus_stack;
        List.iter (Seat.op_end ctx) wm.seats;
        Option.iter (Output.mark_dirty wm) window.output;
        Output.move_window window o;
        Output.mark_dirty wm o;
        Window.fullscreen ctx window
    in
    (match window.presentation with
     | P_tiled | P_floating | P_maximized _ -> enter ()
     | P_fullscreen _ ->
       (match r.output, window.output with
        | Some o1, Some o2 when o1 != o2 ->
          Output.mark_dirty wm o2;
          Output.move_window window o1;
          Output.mark_dirty wm o1;
          Window.fullscreen ~force:true ctx window
        | _, _ -> ()))
  | Req_exit_fullscreen ->
    (match window.presentation with
     | P_tiled | P_floating | P_maximized _ -> ()
     | P_fullscreen _ ->
       Window.exit_fullscreen ctx window;
       Option.iter (Output.mark_dirty wm) window.output)
  | Req_dimensions d ->
    window.geom <- { window.geom with w = d.width; h = d.height };
    let in_resize =
      List.exists
        (fun (s : Seat.t) ->
           match s.op with
           | Op_resize { window = w; _ } when w == window -> true
           | _ -> false)
        wm.seats
    in
    if window.presentation = P_floating && not in_resize
    then Window.fit_to_output ctx window
;;

let focus_request (ctx : Ctx.manage Ctx.t) (seat : Types.Seat.t) =
  let wm = Ctx.wm ctx in
  if wm.config.focus_follows_pointer && seat.op = Op_none && seat.layer_focus = Lf_none
  then (
    match seat.focus_request with
    | Focus_window w ->
      Focus.focus_window ctx seat w ~force:true;
      seat.focus_request <- Focus_none
    | Focus_clear ->
      Focus.clear ctx seat;
      seat.focus_request <- Focus_none
    | _ -> ())
;;

let interaction (ctx : Ctx.manage Ctx.t) (seat : Types.Seat.t) =
  match seat.interacted with
  | None -> ()
  | Some w ->
    Focus.focus_window ctx seat w;
    seat.interacted <- None
;;

let raise_no_focused_window () = dispatch_failed "no focused window"
let raise_seat_missing_output () = dispatch_failed "seat is not attached to any output"

let handle_action (ctx : Ctx.manage Ctx.t) (seat : Types.Seat.t) (action : Action.t) =
  let wm = Ctx.wm ctx in
  match action with
  | Spawn cmd -> Utils.spawn cmd
  | Exit_session -> Window_manager.request_exit wm
  | Close_wm -> Window_manager.request_close wm
  | Close_focused ->
    (match Focus.focused_of seat with
     | None -> raise_no_focused_window ()
     | Some window -> Rwm.River_window_v1.close window.obj)
  | Toggle_floating ->
    (match Focus.focused_of seat with
     | None -> raise_no_focused_window ()
     | Some w ->
       (match w.presentation with
        | P_fullscreen _ ->
          dispatch_failed "cannot toggle float while window is fullscreen"
        | _ ->
          Window.toggle_floating ctx (Some w);
          (match seat.output with
           | None -> raise_seat_missing_output ()
           | Some o -> Output.mark_dirty wm o)))
  | Toggle_maximize ->
    (match Focus.focused_of seat with
     | None -> raise_no_focused_window ()
     | Some w ->
       (match w.presentation with
        | P_maximized _ -> window_request ctx w Req_unmaximize
        | P_tiled | P_floating -> window_request ctx w Req_maximize
        | P_fullscreen _ ->
          dispatch_failed "cannot toggle maximization while window is fullscreen"))
  | Toggle_fake_fullscreen ->
    (match Focus.focused_of seat with
     | None -> raise_no_focused_window ()
     | Some w ->
       (match w.presentation with
        | P_fullscreen _ ->
          dispatch_failed
            "cannot toggle fake fullscreen when window is actually fullscreen"
        | _ ->
          let open Types.Window_request in
          (if w.is_fake_fullscreen then Req_exit_fake_fullscreen else Req_fake_fullscreen)
          |> window_request ctx w))
  | Toggle_fullscreen ->
    (match Focus.focused_of seat with
     | None -> raise_no_focused_window ()
     | Some w ->
       (match w.presentation with
        | P_fullscreen _ -> window_request ctx w Req_exit_fullscreen
        | _ -> window_request ctx w (Req_fullscreen { output = w.output })))
  | Move_interactive ->
    (match seat.op, seat.hovered with
     | Op_none, Some window -> window_request ctx window (Req_move { seat })
     | _ -> dispatch_failed "cannot begin move during an active operation")
  | Resize_interactive ->
    (match seat.op, seat.hovered with
     | Op_none, Some window ->
       window_request
         ctx
         window
         (Req_resize
            { seat
            ; edges =
                Int32.logor
                  Rwm.River_window_v1.Edges.right
                  Rwm.River_window_v1.Edges.bottom
            })
     | _ -> dispatch_failed "cannot begin resize during an active operation")
  | Move_to { x; y } ->
    (match Focus.focused_of seat with
     | None -> raise_no_focused_window ()
     | Some w ->
       if Window.is_fullscreen w
       then dispatch_failed "cannot move a fullscreen window"
       else (
         Window.move_to ctx w ~x ~y;
         Option.iter (Output.mark_dirty wm) w.output))
  | Move_spatial { dir; by } ->
    (match Focus.focused_of seat with
     | None -> raise_no_focused_window ()
     | Some w ->
       if Window.is_fullscreen w
       then dispatch_failed "cannot move a fullscreen window"
       else (
         Window.move_spatial ctx w dir by;
         Option.iter (Output.mark_dirty wm) w.output))
  | Resize_to { w = width; h = height } ->
    (match Focus.focused_of seat with
     | None -> raise_no_focused_window ()
     | Some w ->
       if Window.is_fullscreen w
       then dispatch_failed "cannot resize a fullscreen window"
       else (
         Window.resize_to ctx w ~width ~height;
         Option.iter (Output.mark_dirty wm) w.output))
  | Resize_spatial { dir; by } ->
    (match Focus.focused_of seat with
     | None -> raise_no_focused_window ()
     | Some w ->
       if Window.is_fullscreen w
       then dispatch_failed "cannot resize a fullscreen window"
       else (
         Window.resize_spatial ctx w dir by;
         Option.iter (Output.mark_dirty wm) w.output))
  | Send_to_output_logical { dir; policy } ->
    dispatch_failed "Send_to_output_logical: not implemented"
  | Send_to_output_spatial { dir; policy } ->
    dispatch_failed "Send_to_output_spatial: not implemented"
  | Send_to_output_name { name; policy } ->
    dispatch_failed "Send_to_output_name: not implemented"
  | Focus_window_logical dir -> Focus.focus_window_logical ctx seat dir
  | Focus_window_spatial dir -> Focus.focus_window_spatial ctx seat dir
  | Focus_window_query q -> Focus.focus_window_query ctx seat q
  | Focus_output_logical dir -> Focus.focus_output_logical ctx seat dir
  | Focus_output_spatial dir -> Focus.focus_output_spatial ctx seat dir
  | Focus_output_name name -> Focus.focus_output_name ctx seat name
  | Shift dir ->
    (match seat.output with
     | None -> raise_seat_missing_output ()
     | Some o ->
       Output.shift dir o;
       Output.mark_dirty wm o)
  | Zoom -> Focus.zoom ctx seat
  | Tag_view arg ->
    (match seat.output with
     | None -> raise_seat_missing_output ()
     | Some o ->
       let s = Output.resolve_tag_arg arg o in
       if Tag_set.is_empty s
       then dispatch_failed "tag set is empty"
       else (
         Output.switch_tags o s;
         Output.mark_dirty wm o))
  | Tag_toggle_view s when Tag_set.is_empty s -> dispatch_failed "tag set is empty"
  | Tag_toggle_view s ->
    (match seat.output with
     | None -> raise_seat_missing_output ()
     | Some o ->
       let new_tags = Tag_set.symmetric_diff o.selected_tags s in
       if Tag_set.is_empty new_tags
       then dispatch_failed "toggle would leave no tags visible"
       else (
         Output.switch_tags o new_tags;
         Output.mark_dirty wm o))
  | Tag_view_previous ->
    (match seat.output with
     | None -> raise_seat_missing_output ()
     | Some o when Tag_set.is_empty o.previous_tags ->
       dispatch_failed "no previous tags defined"
     | Some o ->
       Output.switch_tags o o.previous_tags;
       Output.mark_dirty wm o)
  | Tag_view_cycle dir ->
    (match seat.output with
     | None -> raise_seat_missing_output ()
     | Some o ->
       let target =
         match dir with
         | Next -> Tag_set.next o.selected_tags
         | Prev -> Tag_set.prev o.selected_tags
       in
       Output.switch_tags o target;
       Output.mark_dirty wm o)
  | Tag_view_cycle_occupied dir ->
    (match seat.output with
     | None -> raise_seat_missing_output ()
     | Some o ->
       let target =
         match dir with
         | Next ->
           let occupied = Output.occupied_tags o in
           Tag_set.next_occupied ~selected:o.selected_tags ~occupied
         | Prev ->
           let occupied = Output.occupied_tags o in
           Tag_set.prev_occupied ~selected:o.selected_tags ~occupied
       in
       Output.switch_tags o target;
       Output.mark_dirty wm o)
  | Window_tag arg ->
    (match Focus.focused_of seat with
     | None -> raise_no_focused_window ()
     | Some w ->
       let s =
         let open Tag_arg in
         match w.output, arg with
         | Some o, _ -> Output.resolve_tag_arg arg o
         | None, Tags_concrete s -> s
         | None, Tags_occupied ->
           dispatch_failed "cannot use 'occupied' for window with no output"
       in
       if Tag_set.is_empty s
       then dispatch_failed "tag set is empty"
       else (
         w.tags <- s;
         Option.iter (Output.mark_dirty wm) w.output))
  | Window_toggle_tag s when Tag_set.is_empty s -> dispatch_failed "tag set is empty"
  | Window_toggle_tag s ->
    (match Focus.focused_of seat with
     | None -> raise_no_focused_window ()
     | Some w ->
       let new_tags = Tag_set.symmetric_diff w.tags s in
       if Tag_set.is_empty new_tags
       then dispatch_failed "toggle would leave window invisible"
       else (
         w.tags <- new_tags;
         Option.iter (Output.mark_dirty wm) w.output))
  | Layout_set name ->
    (match Layout.find ~registry:wm.layout_registry ~name with
     | None -> dispatch_failed @@ Printf.sprintf "no registered layout named: %S" name
     | Some entry ->
       (match seat.output with
        | None -> dispatch_failed "ocdwm does not have a focused output"
        | Some o ->
          let old_name = Output.current_layout_entry o |> Layout.entry_name in
          if old_name = "floating"
          then Output.tiled_windows o |> List.iter Window.remember_float;
          Output.set_layout_entry o ~entry;
          Output.mark_dirty wm o))
  | Layout_cycle dir ->
    (match seat.output with
     | None -> dispatch_failed "ocdwm does not have a focused output"
     | Some o ->
       let name = Output.current_layout_entry o |> Layout.entry_name in
       (match Layout.cycle ~registry:wm.layout_registry ~name ~dir with
        | None -> dispatch_failed "unable to cycle, no other layouts registered"
        | Some (_, entry) ->
          if name = "floating"
          then Output.tiled_windows o |> List.iter Window.remember_float;
          Output.set_layout_entry o ~entry;
          Output.mark_dirty wm o))
  | Set_mfact delta ->
    (match seat.output with
     | None -> raise_seat_missing_output ()
     | Some o -> Output.set_mfact ~delta wm o)
  | Set_nmaster delta ->
    (match seat.output with
     | None -> raise_seat_missing_output ()
     | Some o -> Output.set_nmaster ~delta wm o)
  | Set_gaps_inner delta ->
    (match seat.output with
     | None -> raise_seat_missing_output ()
     | Some o -> Output.set_gaps_inner ~delta wm o)
  | Set_gaps_outer delta ->
    (match seat.output with
     | None -> raise_seat_missing_output ()
     | Some o -> Output.set_gaps_outer ~delta wm o)
  | Set_stack kind ->
    (match seat.output with
     | None -> raise_seat_missing_output ()
     | Some o -> Output.set_stack_kind ~kind wm o)
;;

let handle_setting (ctx : Ctx.manage Ctx.t) (seat : Types.Seat.t) (setting : Setting.t) =
  match setting with
  | Bind bind ->
    (match Keybind.parse bind.keybind with
     | Error msg -> dispatch_failed msg
     | Ok { mods; key = Keysym keysym } ->
       Seat.replace_xkb_binding ctx seat mods keysym bind.action
     | Ok { mods; key = Pointer button } ->
       Seat.replace_pointer_binding ctx seat mods button bind.action)
  | Unbind keybind ->
    (match Keybind.parse keybind with
     | Error msg -> dispatch_failed msg
     | Ok { mods; key = Keysym keysym } -> Seat.unbind_xkb_binding ctx seat mods keysym
     | Ok { mods; key = Pointer button } ->
       Seat.unbind_pointer_binding ctx seat mods button)
;;

let handle
      (ctx : Ctx.manage Ctx.t)
      (seat : Types.Seat.t)
      ({ body; reply } : Pending_request.t)
  =
  let result =
    try
      (match body with
       | Trigger action -> handle_action ctx seat action
       | Setting setting -> handle_setting ctx seat setting);
      Ok ()
    with
    | Exceptions.Finished -> raise Exceptions.Finished
    | Dispatch_failed msg -> Error msg
    | exn -> Error (Printexc.to_string exn)
  in
  match result, reply with
  | Ok _, None -> ()
  | Error msg, None -> Logs.err @@ fun m -> m "%s" msg
  | _, Some u -> Eio.Promise.resolve u result
;;
