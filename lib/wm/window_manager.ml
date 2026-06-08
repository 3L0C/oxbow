open! Window_manager_state

type t = Types.Window_manager.t

let mark_dirty (wm : t) =
  if not wm.dirty
  then (
    wm.dirty <- true;
    River.Window_management.River_window_manager_v1.manage_dirty wm.river_wm_v1)
;;

let request_focus_output (wm : t) (seat : Types.Seat.t) (output : Types.Output.t option) =
  if not @@ Utils.opts_are_equal seat.output output
  then (
    seat.output <- output;
    mark_dirty wm)
;;

let focused_output (wm : t) = Option.bind wm.primary_seat @@ fun s -> s.output

let default_output (wm : t) =
  match focused_output wm with
  | Some _ as o -> o
  | None -> List.nth_opt wm.outputs 0
;;

let ensure_seat_output (wm : t) (seat : Types.Seat.t) =
  match seat.output with
  | Some _ -> ()
  | None -> default_output wm |> request_focus_output wm seat
;;

let refresh_layer_shell_output (wm : t) =
  match focused_output wm with
  | None -> ()
  | Some o -> River.Layer_shell.River_layer_shell_output_v1.set_default o.layer_shell
;;

let focus_output
      (ctx : Ctx.manage Ctx.t)
      (seat : Types.Seat.t)
      (output : Types.Output.t option)
  =
  let wm = Ctx.wm ctx in
  if not @@ Utils.opts_are_equal seat.output output
  then (
    seat.output <- output;
    if Utils.opt_holds wm.primary_seat seat then refresh_layer_shell_output wm)
;;

let sync (ctx : Ctx.manage Ctx.t) =
  let wm = Ctx.wm ctx in
  if wm.dirty
  then (
    refresh_layer_shell_output wm;
    wm.dirty <- false)
;;

let request_exit ?(origin = `Local) (wm : t) =
  match wm.state with
  | Wm_running ->
    wm.state <- Wm_pending_exit origin;
    mark_dirty wm
  | Wm_pending_exit _ | Wm_exited | Wm_close_requested ->
    Logs.warn
    @@ fun m ->
    m
      "ignoring exit request for non-running state: %s"
      (Window_manager_state.to_string wm.state)
;;

let drain_pending_replies (wm : t) =
  List.iter
    (fun (seat : Types.Seat.t) ->
       Queue.iter
         (fun (p : Pending_request.t) ->
            Option.iter (fun u -> Eio.Promise.resolve_error u "wm shutting down") p.reply)
         seat.pending_requests;
       Queue.clear seat.pending_requests)
    wm.seats
;;

let request_close (wm : t) =
  match wm.state with
  | Wm_running ->
    drain_pending_replies wm;
    wm.state <- Wm_close_requested;
    Eio.Condition.broadcast wm.shutdown
  | Wm_pending_exit _ | Wm_exited | Wm_close_requested ->
    Logs.warn
    @@ fun m ->
    m
      "ignoring close request for non-running state: %s"
      (Window_manager_state.to_string wm.state)
;;

let dispatch_pending (wm : t) =
  match wm.state with
  | Wm_pending_exit _ ->
    drain_pending_replies wm;
    wm.state <- Wm_exited;
    River.Window_management.River_window_manager_v1.exit_session wm.river_wm_v1;
    Eio.Condition.broadcast wm.shutdown
  | Wm_running | Wm_exited | Wm_close_requested ->
    Logs.err
    @@ fun m ->
    m
      "got dispatch_pending request for unhandled state: %s"
      (Window_manager_state.to_string wm.state)
;;

let notify_finished (wm : t) =
  match wm.state with
  | Wm_running ->
    drain_pending_replies wm;
    wm.state <- Wm_close_requested;
    Eio.Condition.broadcast wm.shutdown
  | Wm_pending_exit _ | Wm_exited | Wm_close_requested ->
    Logs.err
    @@ fun m ->
    m
      "got notify_finished for unhandled state: %s"
      (Window_manager_state.to_string wm.state)
;;

let await_shutdown (wm : t) =
  Eio.Condition.loop_no_mutex wm.shutdown
  @@ fun () ->
  match wm.state with
  | Wm_exited | Wm_close_requested -> Some ()
  | Wm_running | Wm_pending_exit _ -> None
;;

let teardown ~(clock : float Eio.Time.clock_ty Eio.Resource.t) (wm : t) =
  Option.iter Init_script.shutdown wm.init_handle;
  match wm.state with
  | Wm_exited ->
    (try
       Eio.Time.with_timeout_exn clock 1.0 (fun () ->
         let rec wait () =
           if Wayland.Proxy.transport_up wm.river_wm_v1
           then (
             Eio.Time.sleep clock 0.05;
             wait ())
         in
         wait ())
     with
     | Eio.Time.Timeout ->
       Logs.warn
       @@ fun m -> m "teardown: river did not close after exit_session within 1s")
  | Wm_close_requested -> ()
  | Wm_running | Wm_pending_exit _ ->
    Logs.err
    @@ fun m ->
    m
      "teardown triggered in unexpected state: %s"
      (Window_manager_state.to_string wm.state)
;;
