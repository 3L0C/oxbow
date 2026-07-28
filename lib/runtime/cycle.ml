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
         | Active -> false)
      wm.outputs
  in
  let first = List.nth_opt retained 0 in
  Wm.set_outputs wm retained;
  List.iter
    (fun (s : Seat.t) ->
       match s.output with
       | Some o when List.memq o removed -> Focus.set_output (Ctx.wm ctx) s first
       | _ -> ())
    wm.seats;
  List.iter
    (fun (w : Window.t) ->
       match w.output with
       | Some o when List.memq o removed -> Window.set_output w None
       | _ -> ())
    wm.windows;
  List.iter
    (fun (o : Output.t) -> Emit.destroy_output ~output:o.obj ~layer_shell:o.layer_shell)
    removed
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
            Focus.remove_window (Ctx.wm ctx) w;
            List.iter
              (fun (c : Window.t) ->
                 if Phys.opt_holds w c.parent then Window.set_parent c ~parent:None)
              wm.windows;
            Window.destroy w;
            Schedule.manage ();
            false
          | New | Active -> true)
       wm.windows
;;

let close_seats ctx =
  let wm = Ctx.wm ctx in
  Wm.set_seats wm
  @@ List.filter
       (fun (s : Seat.t) ->
          match s.lifecycle with
          | Closing ->
            Emit.destroy_seat ~seat:s.obj ~layer_shell:s.layer_shell;
            false
          | _ -> true)
       wm.seats
;;

let manage_new_window ctx (window : Window.t) =
  let wm = Ctx.wm ctx in
  Option.iter (Stacking.push [ window ]) window.output;
  if window.is_fixed || Option.is_some window.parent
  then Window.set_presentation window Floating;
  Rules.apply_for wm window;
  Window.set_lifecycle window Active;
  match window.output with
  | Some o ->
    if
      window.presentation = Floating
      || (window.presentation = Tiled && Output.current_layout o = Floating)
    then Window.set_float_seed_pending window true
  | _ -> ()
;;

let manage_window ctx (window : Window.t) =
  let wm = Ctx.wm ctx in
  List.rev window.requests |> List.iter (Window_request.handle wm window);
  Window.clear_requests window
;;

let manage_new_seat ctx (seat : Seat.t) =
  match seat.lifecycle with
  | Active | Closing -> ()
  | New ->
    let wm = Ctx.wm ctx in
    Bind.install_defaults wm seat;
    Seat.set_lifecycle seat Active;
    (match wm.init_handle, wm.init_command with
     | None, Some cmd when Phys.opt_holds seat wm.primary_seat ->
       let init_handle = Init_script.fork ~cmd in
       Wm.set_init_handle wm @@ Some init_handle;
       Logs.debug @@ fun m -> m "init script forked: pid=%d" init_handle.pid
     | _ -> ())
;;

let manage_seat ctx seat =
  let rec drain () =
    match Seat.drain_pending seat with
    | None -> ()
    | Some r ->
      Dispatch.handle ctx seat r;
      drain ()
  in
  let wm = Ctx.wm ctx in
  Focus.seat_sync wm seat;
  Focus.apply_request wm seat;
  Focus.apply_interaction wm seat;
  drain ();
  Drag.step wm seat
;;

let manage_output ctx (output : Output.t) =
  match output.lifecycle with
  | Removed -> ()
  | Active ->
    Arrange.retile ctx output;
    Focus.refresh ctx output
;;

let reap ctx =
  remove_outputs ctx;
  close_windows ctx;
  close_seats ctx
;;

let admit ctx =
  let wm = Ctx.wm ctx in
  Focus.wm_sync wm;
  List.iter (manage_new_seat ctx) wm.seats;
  List.iter
    (fun (w : Window.t) ->
       match w.lifecycle with
       | New -> manage_new_window ctx w
       | Active | Closing -> ())
    wm.windows
;;

let apply ctx =
  let wm = Ctx.wm ctx in
  List.iter (manage_window ctx) wm.windows;
  List.iter (manage_seat ctx) wm.seats
;;

let arrange ctx =
  let wm = Ctx.wm ctx in
  List.iter (manage_output wm) wm.outputs
;;

let publish ctx = Ctx.wm ctx |> Events.publish

let manage (wm : Wm.t) proxy =
  match wm.lifecycle with
  | Pending_exit _ -> Lifecycle.dispatch_pending wm
  | Close_requested -> River.Window_management.River_window_manager_v1.manage_finish proxy
  | Exited -> Logs.err @@ fun m -> m "wayland session should have exited..."
  | Running ->
    Fun.protect
      ~finally:(fun () ->
        River.Window_management.River_window_manager_v1.manage_finish proxy)
      (fun () ->
         Ctx.with_manage wm (fun ctx ->
           Focus.layer_shell_sync wm;
           reap ctx;
           admit ctx;
           apply ctx;
           arrange ctx;
           Commit.manage ctx;
           publish ctx))
;;

let render wm proxy =
  Ctx.with_render wm (fun ctx ->
    Commit.render ctx;
    River.Window_management.River_window_manager_v1.render_finish proxy)
;;
