(* ocdwm action handler *)
[@@@landmark "auto"]

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

module Layout = Ocdwm_layout.Layout
module Tag_set = Ocdwm_core.Tag_set
module Utils = Ocdwm_core.Utils
open Types
open Ocdwm_ipc.Types

let rec handle_window_request
          (wm : window_manager)
          (window : window)
          (request : window_request)
  =
  Phase.during_manage wm ~op:"handle_window_request"
    (fun () ->
       begin match request with
       | Req_move r ->
           begin match window.presentation with
           | P_fullscreen _ -> ()
           | _ -> begin
               if window.presentation = P_tiled then begin
                 window.presentation <- P_floating;
                 Output.mark_dirty_opt window.output
               end;
               Seat.pointer_move wm r.seat window
             end
           end
       | Req_resize r ->
           begin match window.presentation with
           | P_fullscreen _ -> ()
           | _ -> begin
               if window.presentation = P_tiled then begin
                 window.presentation <- P_floating;
                 Output.mark_dirty_opt window.output
               end;
               Seat.pointer_resize wm r.seat window r.edges
             end
           end
       | Req_maximize -> begin
           window.is_maximized <- true;
           Rwm.River_window_v1.inform_fullscreen window.obj
         end
       | Req_unmaximize -> begin
           window.is_maximized <- false;
           Rwm.River_window_v1.inform_not_fullscreen
             window.obj
         end
       | Req_fullscreen r -> begin
           let enter (restore : [ `Tiled | `Floating ]) =
             match (r.output, window.output) with
             | None, None -> ()
             | Some o, _
             | None, Some o -> begin
                 List.iter
                   (fun w ->
                      if
                        Window.tag_visible w
                        && Window.is_fullscreen w
                      then
                        handle_window_request wm w
                          Req_exit_fullscreen)
                   o.focus_stack;
                 List.iter
                   (fun (s : seat) ->
                      match s.op with
                      | Op_move op when op.window == window
                        ->
                          s.op <- Op_none
                      | Op_resize op
                        when op.window == window ->
                          s.op <- Op_none
                      | _ -> ())
                   wm.seats;
                 (* window.presentation <- P_fullscreen { restore }; *)
                 Output.mark_dirty_opt window.output;
                 Output.move_window window o;
                 Output.mark_dirty o;
                 Window.fullscreen wm window restore
               end
           in
           match window.presentation with
           | P_tiled -> enter `Tiled
           | P_floating -> enter `Floating
           | P_fullscreen d ->
               begin match (r.output, window.output) with
               | Some o1, Some o2 when o1 != o2 ->
                   Output.mark_dirty o2;
                   Output.move_window window o1;
                   Output.mark_dirty o1;
                   Window.fullscreen wm window d.restore
               | _, _ -> ()
               end
         end
       | Req_exit_fullscreen ->
           begin match window.presentation with
           | P_tiled
           | P_floating ->
               ()
           | P_fullscreen { restore } -> begin
               Window.exit_fullscreen wm window restore;
               Output.mark_dirty_opt window.output
             end
           end
       | Req_dimensions d -> begin
           window.geom <-
             { window.geom with w = d.width; h = d.height };
           let in_resize =
             List.exists
               (fun (s : seat) ->
                  match s.op with
                  | Op_resize { window = w; _ }
                    when w == window ->
                      true
                  | _ -> false)
               wm.seats
           in
           if
             window.presentation = P_floating
             && not in_resize
           then Window.fit_to_output wm window
         end
       end)

let handle_action
      (wm : window_manager)
      (seat : seat)
      (action : action)
  =
  Phase.during_manage wm ~op:"handle_action" (fun () ->
    begin match action with
    | No_action -> ()
    | Spawn cmd -> Utils.spawn cmd
    | Exit_wm -> begin
        Rwm.River_window_manager_v1.exit_session
          wm.river_wm_v1;
        raise Finished
      end
    | Close_focused ->
        begin match Focus.focused_of seat with
        | Some window ->
            Rwm.River_window_v1.close window.obj
        | None -> ()
        end
    | Toggle_floating ->
        begin match Focus.focused_of seat with
        | None -> ()
        | Some w ->
            begin match w.presentation with
            | P_fullscreen _ -> ()
            | _ -> begin
                Window.toggle_floating wm (Some w);
                Output.mark_dirty_opt seat.output
              end
            end
        end
    | Toggle_maximize ->
        begin match Focus.focused_of seat with
        | None -> ()
        | Some w ->
            begin match w.presentation with
            | P_fullscreen _ -> ()
            | _ ->
                (if w.is_maximized then Req_unmaximize
                 else Req_maximize)
                |> handle_window_request wm w
            end
        end
    | Toggle_fullscreen ->
        begin match Focus.focused_of seat with
        | None -> ()
        | Some w ->
            begin match w.presentation with
            | P_fullscreen _ ->
                handle_window_request wm w
                  Req_exit_fullscreen
            | _ ->
                handle_window_request wm w
                  (Req_fullscreen { output = w.output })
            end
        end
    | Move_interactive ->
        begin match (seat.op, seat.hovered) with
        | Op_none, Some window -> begin
            handle_window_request wm window
              (Req_move { seat })
          end
        | _, _ -> ()
        end
    | Resize_interactive ->
        begin match (seat.op, seat.hovered) with
        | Op_none, Some window -> begin
            handle_window_request wm window
              (Req_resize
                 {
                   seat;
                   edges =
                     Int32.logor
                       Rwm.River_window_v1.Edges.right
                       Rwm.River_window_v1.Edges.bottom;
                 })
          end
        | _, _ -> ()
        end
    | Send_to_output dir ->
        failwith "Send_to_output: not implemented"
    | Send_to_output_tags dir ->
        failwith "Send_to_output_tags: not implemented"
    | Focus_window dir -> Focus.focus_dir wm seat dir
    | Focus_output dir -> Focus.focus_output wm seat dir
    | Swap_window dir ->
        failwith "Swap_window: not implemented"
    | Zoom -> failwith "Zoom: not implemented"
    | Tag_view n when not @@ Tag_set.in_range n -> begin
        Logs.err (fun m ->
          m "Tag_view refusing: %d outside range [%d..%d]" n
            Tag_set.min_tag Tag_set.max_tag)
      end
    | Tag_view n ->
        begin match seat.output with
        | None -> ()
        | Some o -> begin
            Tag_set.singleton n |> Output.switch_tags o;
            Output.mark_dirty o
          end
        end
    | Tag_view_mask s when Tag_set.is_empty s ->
        Logs.err (fun m ->
          m
            "Tag_view_mask refusing: zero mask (would \
             leave no tags visible)")
    | Tag_view_mask s ->
        begin match seat.output with
        | None -> ()
        | Some o -> begin
            Output.switch_tags o s;
            Output.mark_dirty o
          end
        end
    | Tag_toggle_view n when not @@ Tag_set.in_range n ->
        Logs.err (fun m ->
          m
            "Tag_toggle_view refusing: %d outside tag \
             range 1-32"
             n)
    | Tag_toggle_view n ->
        begin match seat.output with
        | None -> ()
        | Some o -> begin
            let new_tags =
              Tag_set.(
                singleton n
                |> symmetric_diff o.selected_tags)
            in
            if Tag_set.is_empty new_tags then
              Logs.err (fun m ->
                m
                  "Tag_toggle_view refusing: toggle (would \
                   leave no tags visible)")
            else begin
              Output.switch_tags o new_tags;
              Output.mark_dirty o
            end
          end
        end
    | Tag_view_previous ->
        begin match seat.output with
        | None -> ()
        | Some o when Tag_set.is_empty o.previous_tags ->
            Logs.warn (fun m ->
              m
                "Tag_view_previous refusing: no previous \
                 tags defined")
        | Some o -> begin
            Output.switch_tags o o.previous_tags;
            Output.mark_dirty o
          end
        end
    | Tag_view_cycle dir ->
        begin match seat.output with
        | None -> ()
        | Some o -> begin
            let target =
              match dir with
              | Dir_next -> begin
                  let occupied = Output.occupied_tags o in
                  Tag_set.next_occupied
                    ~selected:o.selected_tags ~occupied
                end
              | Dir_prev -> begin
                  let occupied = Output.occupied_tags o in
                  Tag_set.prev_occupied
                    ~selected:o.selected_tags ~occupied
                end
              | Dir_down
              | Dir_right ->
                  Tag_set.next o.selected_tags
              | Dir_up
              | Dir_left ->
                  Tag_set.prev o.selected_tags
            in
            Output.switch_tags o target;
            Output.mark_dirty o
          end
        end
    | Window_tag n when not @@ Tag_set.in_range n -> begin
        Logs.err (fun m ->
          m "Window_tag refusing: %d outside range [%d..%d]"
            n Tag_set.min_tag Tag_set.max_tag)
      end
    | Window_tag n ->
        begin match Focus.focused_of seat with
        | None -> ()
        | Some w -> begin
            w.tags <- Tag_set.singleton n;
            Output.mark_dirty_opt w.output
          end
        end
    | Window_toggle_tag n when not @@ Tag_set.in_range n ->
    begin
        Logs.err (fun m ->
          m
            "Window_toggle_tag refusing: %d outside range \
             [%d..%d]"
             n Tag_set.min_tag Tag_set.max_tag)
      end
    | Window_toggle_tag n ->
        begin match Focus.focused_of seat with
        | None -> ()
        | Some w -> begin
            let new_tags =
              Tag_set.(singleton n |> symmetric_diff w.tags)
            in
            if Tag_set.is_empty new_tags then
              Logs.err (fun m ->
                m
                  "Window_toggle_tag refusing: toggle \
                   (would leave window invisible)")
            else begin
              w.tags <- new_tags;
              Output.mark_dirty_opt w.output
            end
          end
        end
    | Window_tag_mask s when Tag_set.is_empty s -> begin
        Logs.err (fun m ->
          m
            "Window_tag_mask refusing: zero mask (would \
             leave window invisible)")
      end
    | Window_tag_mask s ->
        begin match Focus.focused_of seat with
        | None -> ()
        | Some w -> begin
            w.tags <- s;
            Output.mark_dirty_opt w.output
          end
        end
    | Layout_set name ->
        begin match
          Layout.find ~registry:wm.layout_registry ~name
        with
        | None -> ()
        | Some entry ->
            begin match wm.focused_output with
            | None -> ()
            | Some o -> begin
                let old_name =
                  Output.current_layout_entry o
                  |> Layout.entry_name
                in
                if old_name = "floating" then
                  Output.tiled_windows o
                  |> List.iter Window.remember_float;
                Output.set_layout_entry o ~entry;
                Output.mark_dirty o
              end
            end
        end
    | Layout_cycle dir ->
        begin match wm.focused_output with
        | None -> ()
        | Some o -> begin
            let name =
              Output.current_layout_entry o
              |> Layout.entry_name
            in
            match
              Layout.cycle ~registry:wm.layout_registry
                ~name ~dir
            with
            | None -> ()
            | Some (_, entry) -> begin
                if name = "floating" then
                  Output.tiled_windows o
                  |> List.iter Window.remember_float;
                Output.set_layout_entry o ~entry;
                Output.mark_dirty o
              end
          end
        end
    | Set_mfact d -> failwith "Set_mfact: not implemented"
    | Set_nmaster delta ->
        failwith "Set_nmaster: not implemented"
    | Set_gaps_inner delta ->
        failwith "Set_gaps_inner: not implemented"
    | Set_gaps_outer delta ->
        failwith "Set_gaps_outer: not implemented"
    | Set_stack stack_kind ->
        failwith "Set_stack: not implemented"
    end)
