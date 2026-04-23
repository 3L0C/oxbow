(* ocdwm action handler *)

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

module Layout = Ocdwm_layout.Layout
open Types
open Ocdwm_ipc.Types

let rec handle_window_request
          (wm : window_manager)
          (window : window)
  = function
  | Req_none -> ()
  | Req_move r ->
      begin match window.presentation with
      | P_fullscreen _ -> ()
      | _ -> begin
          if window.presentation = P_tiled then begin
            window.presentation <- P_floating;
            Output.mark_dirty window.output
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
            Output.mark_dirty window.output
          end;
          Seat.pointer_resize wm r.seat window r.edges
        end
      end
  | Req_maximize -> begin
      window.is_maximized <- true;
      Rwm.River_window_v1.inform_maximized window.obj
    end
  | Req_unmaximize -> begin
      window.is_maximized <- false;
      Rwm.River_window_v1.inform_unmaximized window.obj
    end
  | Req_fullscreen r -> begin
      let enter (restore : [ `Tiled | `Floating ]) =
        match (r.output, window.output) with
        | None, None -> ()
        | Some o, _
        | None, Some o -> begin
            List.iter
              (fun w ->
                 if Window.is_fullscreen w then
                   handle_window_request wm w
                     Req_exit_fullscreen)
              o.focus_stack;
            List.iter
              (fun (s : seat) ->
                 match s.op with
                 | Op_move op when op.window == window ->
                     s.op <- Op_none
                 | Op_resize op when op.window == window ->
                     s.op <- Op_none
                 | _ -> ())
              wm.seats;
            window.presentation <- P_fullscreen { restore };
            Output.mark_dirty window.output;
            Output.move_window window o;
            Output.mark_dirty (Some o);
            Window.fullscreen window
          end
      in
      match window.presentation with
      | P_tiled -> enter `Tiled
      | P_floating -> enter `Floating
      | P_fullscreen _ ->
          begin match (r.output, window.output) with
          | Some o1, Some o2 when o1 != o2 ->
              Output.mark_dirty (Some o2);
              Output.move_window window o1;
              Output.mark_dirty (Some o1);
              Window.fullscreen window
          | _, _ -> ()
          end
    end
  | Req_exit_fullscreen ->
      begin match window.presentation with
      | P_tiled
      | P_floating ->
          ()
      | P_fullscreen { restore } -> begin
          Window.exit_fullscreen window restore;
          Output.mark_dirty window.output
        end
      end

let handle_action (wm : window_manager) (seat : seat)
  = function
  | No_action -> ()
  | Spawn cmd -> Ocdwm_core.Utils.spawn cmd
  | Close_focused ->
      begin match Focus.focused_of seat with
      | Some window -> Rwm.River_window_v1.close window.obj
      | None -> ()
      end
  | Focus_window dir -> Focus.focus_dir wm seat dir
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
  | Exit_wm ->
      Rwm.River_window_manager_v1.exit_session
        wm.river_wm_v1
  | Toggle_floating ->
      begin match Focus.focused_of seat with
      | None -> ()
      | Some w ->
          begin match w.presentation with
          | P_fullscreen _ -> ()
          | _ -> begin
              Window.toggle_floating (Some w);
              Output.mark_dirty seat.output
            end
          end
      end
  | Toggle_fullscreen ->
      begin match Focus.focused_of seat with
      | None -> ()
      | Some w ->
          begin match w.presentation with
          | P_fullscreen _ ->
              handle_window_request wm w Req_exit_fullscreen
          | _ ->
              handle_window_request wm w
                (Req_fullscreen { output = w.output })
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
              Output.mark_dirty (Some o)
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
            Layout.cycle ~registry:wm.layout_registry ~name
              ~dir
          with
          | None -> ()
          | Some (_, entry) -> begin
              if name = "floating" then
                Output.tiled_windows o
                |> List.iter Window.remember_float;
              Output.set_layout_entry o ~entry;
              Output.mark_dirty (Some o)
            end
        end
      end
  | _ -> ()
