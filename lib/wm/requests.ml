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
    (match window.presentation with
     | P_fullscreen _ -> ()
     | _ ->
       if window.presentation = P_tiled && (not @@ Output.is_floating window.output)
       then (
         window.presentation <- P_floating;
         Option.iter (Output.mark_dirty wm) window.output);
       Input.pointer_move ctx r.seat window)
  | Req_resize r ->
    (match window.presentation with
     | P_fullscreen _ -> ()
     | _ ->
       if window.presentation = P_tiled && (not @@ Output.is_floating window.output)
       then (
         window.presentation <- P_floating;
         Option.iter (Output.mark_dirty wm) window.output);
       Input.pointer_resize ctx r.seat window r.edges)
  | Req_maximize ->
    window.is_maximized <- true;
    Rwm.River_window_v1.inform_fullscreen window.obj
  | Req_unmaximize ->
    window.is_maximized <- false;
    Rwm.River_window_v1.inform_not_fullscreen window.obj
  | Req_fullscreen r ->
    let enter (restore : [ `Tiled | `Floating ]) =
      match r.output, window.output with
      | None, None -> ()
      | Some o, _ | None, Some o ->
        List.iter
          (fun w ->
             if Window.tag_visible w && Window.is_fullscreen w
             then window_request ctx w Req_exit_fullscreen)
          o.focus_stack;
        List.iter
          (fun (s : Seat.t) ->
             match s.op with
             | Op_move op when op.window == window -> s.op <- Op_none
             | Op_resize op when op.window == window -> s.op <- Op_none
             | _ -> ())
          wm.seats;
        Option.iter (Output.mark_dirty wm) window.output;
        Output.move_window window o;
        Output.mark_dirty wm o;
        Window.fullscreen ctx window restore
    in
    (match window.presentation with
     | P_tiled -> enter `Tiled
     | P_floating -> enter `Floating
     | P_fullscreen d ->
       (match r.output, window.output with
        | Some o1, Some o2 when o1 != o2 ->
          Output.mark_dirty wm o2;
          Output.move_window window o1;
          Output.mark_dirty wm o1;
          Window.fullscreen ctx window d.restore
        | _, _ -> ()))
  | Req_exit_fullscreen ->
    (match window.presentation with
     | P_tiled | P_floating -> ()
     | P_fullscreen { restore } ->
       Window.exit_fullscreen ctx window restore;
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
  | No_action -> ()
  | Spawn cmd -> Utils.spawn cmd
  | Exit_wm ->
    wm.pending_exit_session <- true;
    wm.dirty <- true;
    Rwm.River_window_manager_v1.manage_dirty wm.river_wm_v1
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
        | P_fullscreen _ -> ()
        | _ ->
          Types.Window_request.(if w.is_maximized then Req_unmaximize else Req_maximize)
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
  | Focus_window dir -> Focus.focus_dir ctx seat dir
  | Focus_output dir -> Focus.focus_output ctx seat dir
  | Swap_window dir -> Logs.err (fun m -> m "Swap_window: not implemented")
  | Zoom -> Focus.zoom ctx seat
  | Tag_view n when not @@ Tag_set.in_range n ->
    Logs.err (fun m ->
      m "Tag_view refusing: %d outside range [%d..%d]" n Tag_set.min_tag Tag_set.max_tag)
  | Tag_view n ->
    (match seat.output with
     | None -> ()
     | Some o ->
       Tag_set.singleton n |> Output.switch_tags o;
       Output.mark_dirty wm o)
  | Tag_view_mask s when Tag_set.is_empty s ->
    Logs.err (fun m ->
      m "Tag_view_mask refusing: zero mask (would leave no tags visible)")
  | Tag_view_mask s ->
    (match seat.output with
     | None -> ()
     | Some o ->
       Output.switch_tags o s;
       Output.mark_dirty wm o)
  | Tag_toggle_view n when not @@ Tag_set.in_range n ->
    Logs.err (fun m -> m "Tag_toggle_view refusing: %d outside tag range 1-32" n)
  | Tag_toggle_view n ->
    (match seat.output with
     | None -> ()
     | Some o ->
       let new_tags = Tag_set.(singleton n |> symmetric_diff o.selected_tags) in
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
  | Window_tag n when not @@ Tag_set.in_range n ->
    Logs.err (fun m ->
      m "Window_tag refusing: %d outside range [%d..%d]" n Tag_set.min_tag Tag_set.max_tag)
  | Window_tag n ->
    (match Focus.focused_of seat with
     | None -> ()
     | Some w ->
       w.tags <- Tag_set.singleton n;
       Option.iter (Output.mark_dirty wm) w.output)
  | Window_toggle_tag n when not @@ Tag_set.in_range n ->
    Logs.err (fun m ->
      m
        "Window_toggle_tag refusing: %d outside range [%d..%d]"
        n
        Tag_set.min_tag
        Tag_set.max_tag)
  | Window_toggle_tag n ->
    (match Focus.focused_of seat with
     | None -> ()
     | Some w ->
       let new_tags = Tag_set.(singleton n |> symmetric_diff w.tags) in
       if Tag_set.is_empty new_tags
       then
         Logs.err (fun m ->
           m "Window_toggle_tag refusing: toggle (would leave window invisible)")
       else (
         w.tags <- new_tags;
         Option.iter (Output.mark_dirty wm) w.output))
  | Window_tag_mask s when Tag_set.is_empty s ->
    Logs.err (fun m ->
      m "Window_tag_mask refusing: zero mask (would leave window invisible)")
  | Window_tag_mask s ->
    (match Focus.focused_of seat with
     | None -> ()
     | Some w ->
       w.tags <- s;
       Option.iter (Output.mark_dirty wm) w.output)
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
