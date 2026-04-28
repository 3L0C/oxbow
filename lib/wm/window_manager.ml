(* ocdwm window manager - state management *)

module Layout = Ocdwm_layout.Layout
module Config = Ocdwm_config.Config
open Types
open Ocdwm_core.Types
open Ocdwm_ipc.Types
open Ocdwm_config.Types

exception Unavailable
exception Finished

let handle_unavailable _proxy =
  Printf.eprintf
    "error: another window manager is already running\n";
  raise Unavailable

let handle_finished _ = raise Finished

let set_presentation_mode (output : output) =
  match Output.focused_window output with
  | Some w when w.output <> None -> begin
      let mode =
        match w.presentation_hint with
        | Some p -> p
        | None ->
            Rwm.River_output_v1.Presentation_mode.Vsync
      in
      Rwm.River_output_v1.set_presentation_mode output.obj
        ~mode
    end
  | _ ->
      Rwm.River_output_v1.set_presentation_mode output.obj
        ~mode:Rwm.River_output_v1.Presentation_mode.Vsync

let render (wm : window_manager) (seat : seat) =
  begin match seat.op with
  | Op_none -> ()
  | Op_move op_m ->
      Window.set_position op_m.window
        ~x:(Int32.add op_m.start_x op_m.dx)
        ~y:(Int32.add op_m.start_y op_m.dy)
  | Op_resize op_r ->
      let x =
        if
          Int32.logand op_r.edges
            Rwm.River_window_v1.Edges.left
          <> 0l
        then
          Int32.sub op_r.start_w op_r.window.geom.w
          |> Int32.add op_r.start_x
        else op_r.start_x
      in
      let y =
        if
          Int32.logand op_r.edges
            Rwm.River_window_v1.Edges.top
          <> 0l
        then
          Int32.sub op_r.start_h op_r.window.geom.h
          |> Int32.add op_r.start_y
        else op_r.start_y
      in
      Window.set_position op_r.window ~x ~y
  end;
  List.iter set_presentation_mode wm.outputs

let manage_seat (wm : window_manager) (seat : seat) =
  Seat.handle_new wm seat;
  Seat.refresh_cursor_target wm seat;
  Seat.handle_focus_request wm seat;
  Seat.handle_interaction wm seat;
  Action.handle_action wm seat seat.pending_action;
  seat.pending_action <- No_action;
  Seat.op wm seat

let manage_window (wm : window_manager) (window : window) =
  begin match window.state with
  | W_new -> begin
      Rwm.River_window_v1.set_capabilities window.obj
        ~caps:
          Rwm.River_window_v1.Capabilities.(
            Int32.logor maximize fullscreen);
      Output.add_window window;
      Output.mark_dirty_opt window.output;
      if window.is_fixed then
        window.presentation <- P_floating;
      window.state <- W_active
    end
  | _ -> ()
  end;
  List.rev window.requests
  |> List.iter (Action.handle_window_request wm window);
  Window.clear_requests window

let remove_outputs (wm : window_manager) =
  wm.outputs <-
    List.filter
      (fun (o : output) ->
         match o.state with
         | O_dirty
         | O_active ->
             true
         | O_removed -> begin
             Output.destroy o;
             false
           end)
      wm.outputs;
  if wm.outputs = [] then wm.focused_output <- None

let close_windows (wm : window_manager) =
  wm.windows <-
    List.filter
      (fun (w : window) ->
         match w.state with
         | W_closing -> begin
             Seat.disconnect_seats wm.seats w;
             Focus.remove_window wm w;
             Window.destroy w;
             Output.mark_dirty_opt w.output;
             false
           end
         | _ -> true)
      wm.windows

let close_seats (wm : window_manager) =
  wm.seats <-
    List.filter
      (fun (s : seat) ->
         match s.state with
         | S_closing -> begin
             Seat.destroy s;
             false
           end
         | _ -> true)
      wm.seats

let manage_output (wm : window_manager) (output : output) =
  begin match output.state with
  | O_dirty ->
      Some output |> Output.retile wm;
      Some output |> Focus.refresh_focus wm;
      output.state <- O_active
  | _ -> ()
  end

let handle_manage_start proxy (wm_box : wm_box) =
  let wm = Option.get wm_box.body in
  remove_outputs wm;
  close_windows wm;
  close_seats wm;
  Focus.maybe_focus_first_output wm;
  List.iter (manage_window wm) wm.windows;
  List.iter (manage_seat wm) wm.seats;
  List.iter (manage_output wm) wm.outputs;
  List.iter Window.sync wm.windows;
  Rwm.River_window_manager_v1.manage_finish proxy

let handle_render_start proxy (wm_box : wm_box) =
  let wm = Option.get wm_box.body in
  List.iter (render wm) wm.seats;
  Rwm.River_window_manager_v1.render_finish proxy

let handle_session_locked _proxy = ()
let handle_session_unlocked _proxy = ()
