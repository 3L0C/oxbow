module Rwm = Ocdwm_protocol.River_window_management_v1_client
module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
open! Ocdwm_core

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

let action (ctx : Ctx.manage Ctx.t) (seat : Types.Seat.t) (action : Action.t) =
  let wm = Ctx.wm ctx in
  match action with
  | Spawn cmd -> Utils.spawn cmd
  | Exit_session -> Window_manager.request_exit wm
  | Close_wm -> Window_manager.request_close wm
  | Close_focused ->
    (match Focus.focused_of seat with
     | Some window -> Rwm.River_window_v1.close window.obj
     | None -> ())
  | Toggle_floating ->
    (match Focus.focused_of seat with
     | None -> ()
     | Some w ->
       (match w.presentation with
        | P_fullscreen _ -> ()
        | _ ->
          Window.toggle_floating ctx (Some w);
          Option.iter (Output.mark_dirty wm) seat.output))
  | Toggle_maximize ->
    (match Focus.focused_of seat with
     | None -> ()
     | Some w ->
       (match w.presentation with
        | P_maximized _ -> window_request ctx w Req_unmaximize
        | P_tiled | P_floating -> window_request ctx w Req_maximize
        | P_fullscreen _ -> ()))
  | Toggle_fake_fullscreen ->
    (match Focus.focused_of seat with
     | None -> ()
     | Some w ->
       (match w.presentation with
        | P_fullscreen _ -> ()
        | _ ->
          let open Types.Window_request in
          (if w.is_fake_fullscreen then Req_exit_fake_fullscreen else Req_fake_fullscreen)
          |> window_request ctx w))
  | Toggle_fullscreen ->
    (match Focus.focused_of seat with
     | None -> ()
     | Some w ->
       (match w.presentation with
        | P_fullscreen _ -> window_request ctx w Req_exit_fullscreen
        | _ -> window_request ctx w (Req_fullscreen { output = w.output })))
  | Move_interactive ->
    (match seat.op, seat.hovered with
     | Op_none, Some window -> window_request ctx window (Req_move { seat })
     | _, _ -> ())
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
     | _, _ -> ())
  | Send_to_output dir -> Logs.err (fun m -> m "Send_to_output: not implemented")
  | Send_to_output_tags dir ->
    Logs.err (fun m -> m "Send_to_output_tags: not implemented")
  | Focus_window dir -> Focus.focus_window_dir ctx seat dir
  | Focus_output dir -> Focus.focus_output_dir ctx seat dir
  | Rotate_window dir ->
    Option.iter (Output.rotate_window dir) seat.output;
    Option.iter (Output.mark_dirty wm) seat.output
  | Zoom -> Focus.zoom ctx seat
  | Tag_view arg ->
    (match seat.output with
     | None -> ()
     | Some o ->
       let s = Output.resolve_tag_arg arg o in
       if Tag_set.is_empty s
       then Logs.err @@ fun m -> m "Tag_view refusing: tag set is empty"
       else (
         Output.switch_tags o s;
         Output.mark_dirty wm o))
  | Tag_toggle_view s when Tag_set.is_empty s ->
    Logs.err @@ fun m -> m "Tag_toggle_view refusing: tag set is empty"
  | Tag_toggle_view s ->
    (match seat.output with
     | None -> ()
     | Some o ->
       let new_tags = Tag_set.symmetric_diff o.selected_tags s in
       if Tag_set.is_empty new_tags
       then
         Logs.err (fun m ->
           m "Tag_toggle_view refusing: toggle (would leave no tags visible)")
       else (
         Output.switch_tags o new_tags;
         Output.mark_dirty wm o))
  | Tag_view_previous ->
    (match seat.output with
     | None -> ()
     | Some o when Tag_set.is_empty o.previous_tags ->
       Logs.warn (fun m -> m "Tag_view_previous refusing: no previous tags defined")
     | Some o ->
       Output.switch_tags o o.previous_tags;
       Output.mark_dirty wm o)
  | Tag_view_cycle dir ->
    (match seat.output with
     | None -> ()
     | Some o ->
       let target =
         match dir with
         | Dir_next ->
           let occupied = Output.occupied_tags o in
           Tag_set.next_occupied ~selected:o.selected_tags ~occupied
         | Dir_prev ->
           let occupied = Output.occupied_tags o in
           Tag_set.prev_occupied ~selected:o.selected_tags ~occupied
         | Dir_down | Dir_right -> Tag_set.next o.selected_tags
         | Dir_up | Dir_left -> Tag_set.prev o.selected_tags
       in
       Output.switch_tags o target;
       Output.mark_dirty wm o)
  | Window_tag arg ->
    (match Focus.focused_of seat with
     | Some w ->
       let s =
         let open Tag_arg in
         match w.output, arg with
         | Some o, _ -> Output.resolve_tag_arg arg o
         | None, Tags_concrete s -> s
         | None, Tags_occupied -> Tag_set.empty
       in
       if Tag_set.is_empty s
       then Logs.err @@ fun m -> m "Window_tag refusing: tag set is empty"
       else (
         w.tags <- s;
         Option.iter (Output.mark_dirty wm) w.output)
     | _ -> ())
  | Window_toggle_tag s when Tag_set.is_empty s ->
    Logs.err @@ fun m -> m "Window_toggle_tag refusing: tag set is empty"
  | Window_toggle_tag s ->
    (match Focus.focused_of seat with
     | None -> ()
     | Some w ->
       let new_tags = Tag_set.symmetric_diff w.tags s in
       if Tag_set.is_empty new_tags
       then
         Logs.err (fun m ->
           m "Window_toggle_tag refusing: toggle (would leave window invisible)")
       else (
         w.tags <- new_tags;
         Option.iter (Output.mark_dirty wm) w.output))
  | Layout_set name ->
    (match Layout.find ~registry:wm.layout_registry ~name with
     | None -> ()
     | Some entry ->
       (match wm.focused_output with
        | None -> ()
        | Some o ->
          let old_name = Output.current_layout_entry o |> Layout.entry_name in
          if old_name = "floating"
          then Output.tiled_windows o |> List.iter Window.remember_float;
          Output.set_layout_entry o ~entry;
          Output.mark_dirty wm o))
  | Layout_cycle dir ->
    (match wm.focused_output with
     | None -> ()
     | Some o ->
       let name = Output.current_layout_entry o |> Layout.entry_name in
       (match Layout.cycle ~registry:wm.layout_registry ~name ~dir with
        | None -> ()
        | Some (_, entry) ->
          if name = "floating"
          then Output.tiled_windows o |> List.iter Window.remember_float;
          Output.set_layout_entry o ~entry;
          Output.mark_dirty wm o))
  | Set_mfact delta -> Option.iter (Output.set_mfact ~delta wm) seat.output
  | Set_nmaster delta -> Option.iter (Output.set_nmaster ~delta wm) seat.output
  | Set_gaps_inner delta -> Option.iter (Output.set_gaps_inner ~delta wm) seat.output
  | Set_gaps_outer delta -> Option.iter (Output.set_gaps_outer ~delta wm) seat.output
  | Set_stack kind -> Option.iter (Output.set_stack_kind ~kind wm) seat.output
;;
