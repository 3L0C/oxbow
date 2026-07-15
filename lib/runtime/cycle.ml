open! Ocdwm_core
open! Ocdwm_state
open! Ocdwm_ops

let remove_outputs ctx =
  let wm = Ctx.wm ctx in
  let removed, retained =
    List.partition
      (fun (o : Output.t) ->
         match o.lifecycle with
         | Removed -> true
         | Dirty _ | Active -> false)
      wm.outputs
  in
  let first = List.nth_opt retained 0 in
  Wm.set_outputs wm retained;
  List.iter
    (fun (s : Seat.t) ->
       match s.output with
       | Some o when List.memq o removed -> Focus.set_output ctx s first
       | _ -> ())
    wm.seats;
  List.iter
    (fun (w : Window.t) ->
       match w.output with
       | Some o when List.memq o removed -> Window.set_output w None
       | _ -> ())
    wm.windows;
  List.iter Output.destroy removed
;;

let disconnect_seat window (seat : Seat.t) =
  (match seat.hovered with
   | Some w when w == window -> Seat.set_hovered seat None
   | _ -> ());
  (match seat.interacted with
   | Some w when w == window -> Seat.set_interacted seat None
   | _ -> ());
  (match seat.focus_state with
   | Refresh w when w == window -> Seat.set_focus_state seat Idle
   | _ -> ());
  (match seat.cursor_target with
   | Some w when w == window -> Seat.set_cursor_target seat None
   | _ -> ());
  match seat.op with
  | Some (Move { window = w; _ } | Resize { window = w; _ }) when w == window ->
    River.Window_management.River_seat_v1.op_end seat.obj;
    Seat.clear_op seat
  | _ -> ()
;;

let disconnect_seats window = List.iter (disconnect_seat window)

let close_windows ctx =
  let wm = Ctx.wm ctx in
  Wm.set_windows wm
  @@ List.filter
       (fun (w : Window.t) ->
          match w.lifecycle with
          | Closing ->
            disconnect_seats w wm.seats;
            Focus.remove_window ctx w;
            Window.destroy w;
            Option.iter Dirty.mark_output w.output;
            false
          | _ -> true)
       wm.windows
;;

let close_seats ctx =
  let wm = Ctx.wm ctx in
  Wm.set_seats wm
  @@ List.filter
       (fun (s : Seat.t) ->
          match s.lifecycle with
          | Closing ->
            Seat.destroy ctx s;
            false
          | _ -> true)
       wm.seats
;;

let manage_window ctx (window : Window.t) =
  (match window.lifecycle with
   | New ->
     River.Window_management.River_window_v1.set_capabilities
       window.obj
       ~caps:
         River.Window_management.River_window_v1.Capabilities.(
           Int32.logor maximize fullscreen);
     Option.iter (Stacking.push [ window ]) window.output;
     if window.is_fixed then Window.set_presentation window Floating;
     Rules.apply_for ctx window;
     Window.set_lifecycle window Active
   | _ -> ());
  List.rev window.requests |> List.iter (Window_request.handle ctx window);
  Window.clear_requests window;
  Decoration.apply ctx window
;;

let manage_new_seat ctx (seat : Seat.t) =
  match seat.lifecycle with
  | New ->
    Bind.install_defaults ctx seat;
    Seat.set_lifecycle seat Active;
    let wm = Ctx.wm ctx in
    (match wm.init_handle, wm.init_command with
     | None, Some cmd when Phys.opt_holds wm.primary_seat seat ->
       let init_handle = Init_script.fork ~cmd in
       Wm.set_init_handle wm @@ Some init_handle;
       Logs.debug @@ fun m -> m "init script forked: pid=%d" init_handle.pid
     | _ -> ())
  | _ -> ()
;;

let manage_seat ctx seat =
  let rec drain () =
    match Seat.drain_pending seat with
    | None -> ()
    | Some r ->
      Dispatch.handle ctx seat r;
      drain ()
  in
  manage_new_seat ctx seat;
  Focus.seat_sync ctx seat;
  Focus.apply_request ctx seat;
  Focus.apply_interaction ctx seat;
  drain ();
  Drag.step ctx seat
;;

let manage_output ctx (output : Output.t) =
  match output.lifecycle with
  | Dirty { prev } ->
    Arrange.retile ctx output;
    Focus.refresh ctx output;
    Output.set_lifecycle output prev
  | _ -> ()
;;

let manage (wm : Wm.t) proxy =
  match wm.lifecycle with
  | Pending_exit _ -> Lifecycle.dispatch_pending wm
  | Close_requested -> River.Window_management.River_window_manager_v1.manage_finish proxy
  | Exited -> Logs.err @@ fun m -> m "wayland session should have exited..."
  | Running ->
    Ctx.with_manage wm (fun ctx ->
      Lifecycle.sync ctx;
      remove_outputs ctx;
      close_windows ctx;
      close_seats ctx;
      Focus.wm_sync ctx;
      List.iter (manage_window ctx) wm.windows;
      List.iter (manage_seat ctx) wm.seats;
      List.iter (manage_output ctx) wm.outputs;
      List.iter (Window.sync ctx) wm.windows;
      River.Window_management.River_window_manager_v1.manage_finish proxy)
;;

let set_presentation_mode output =
  match Output.focused_window output with
  | Some w when Option.is_some w.output ->
    let mode =
      match w.presentation_hint with
      | Some p -> p
      | None -> River.Window_management.River_output_v1.Presentation_mode.Vsync
    in
    River.Window_management.River_output_v1.set_presentation_mode output.obj ~mode
  | _ ->
    River.Window_management.River_output_v1.set_presentation_mode
      output.obj
      ~mode:River.Window_management.River_output_v1.Presentation_mode.Vsync
;;

let render_impl ctx (seat : Seat.t) =
  let wm = Ctx.wm ctx in
  (match seat.op with
   | None -> ()
   | Some (Move op_m) ->
     Window.set_position
       ctx
       op_m.window
       ~x:(Int32.add op_m.start_x op_m.dx)
       ~y:(Int32.add op_m.start_y op_m.dy)
   | Some (Resize op_r) ->
     let x =
       if Int32.logand op_r.edges River.Window_management.River_window_v1.Edges.left <> 0l
       then Int32.sub op_r.start_w op_r.window.geom.w |> Int32.add op_r.start_x
       else op_r.start_x
     in
     let y =
       if Int32.logand op_r.edges River.Window_management.River_window_v1.Edges.top <> 0l
       then Int32.sub op_r.start_h op_r.window.geom.h |> Int32.add op_r.start_y
       else op_r.start_y
     in
     Window.set_position ctx op_r.window ~x ~y);
  List.iter set_presentation_mode wm.outputs;
  Border.paint ctx
;;

let render wm proxy =
  Ctx.with_render wm (fun ctx ->
    List.iter (render_impl ctx) wm.seats;
    River.Window_management.River_window_manager_v1.render_finish proxy)
;;
