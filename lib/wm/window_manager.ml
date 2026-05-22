module Rwm = Ocdwm_protocol.River_window_management_v1_client
module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
module Xkb = Ocdwm_protocol.River_xkb_bindings_v1_client
open Window_manager_state

type t = Types.Window_manager.t

let set_focused_output (wm : t) (output : Types.Output.t option) =
  wm.focused_output <- output;
  wm.dirty <- true;
  Rwm.River_window_manager_v1.manage_dirty wm.river_wm_v1
;;

let refresh_layer_shell_output (wm : t) =
  match wm.focused_output with
  | None -> ()
  | Some o -> Rlsh.River_layer_shell_output_v1.set_default o.layer_shell
;;

let focus_output (ctx : Ctx.manage Ctx.t) (output : Types.Output.t option) =
  let wm = Ctx.wm ctx in
  wm.focused_output <- output;
  refresh_layer_shell_output wm
;;

let sync (ctx : Ctx.manage Ctx.t) =
  let wm = Ctx.wm ctx in
  if wm.dirty
  then (
    refresh_layer_shell_output wm;
    wm.dirty <- false)
;;

let mark_dirty (wm : t) =
  wm.dirty <- true;
  Rwm.River_window_manager_v1.manage_dirty wm.river_wm_v1
;;

let request_exit ?(origin = `Local) (wm : t) =
  match wm.state with
  | Wm_running ->
    wm.state <- Wm_pending_exit origin;
    mark_dirty wm
  | Wm_pending_exit _ | Wm_pending_close | Wm_close_sent | Wm_exited | Wm_closed ->
    Logs.warn
    @@ fun m ->
    m
      "ignoring exit request for non-running state: %s"
      (Window_manager_state.to_string wm.state)
;;

let request_close (wm : t) =
  match wm.state with
  | Wm_running ->
    wm.state <- Wm_pending_close;
    mark_dirty wm
  | Wm_pending_exit _ | Wm_pending_close | Wm_close_sent | Wm_exited | Wm_closed ->
    Logs.warn
    @@ fun m ->
    m
      "ignoring close request for non-running state: %s"
      (Window_manager_state.to_string wm.state)
;;

let drain_pending_replies (wm : t) =
  List.iter
    (fun (seat : Types.Seat.t) ->
       Queue.iter
         (fun (p : Pending_action.t) ->
            Option.iter (fun u -> Eio.Promise.resolve_error u "wm shutting down") p.reply)
         seat.pending_actions;
       Queue.clear seat.pending_actions)
    wm.seats
;;

let dispatch_pending (wm : t) =
  match wm.state with
  | Wm_pending_exit _ ->
    drain_pending_replies wm;
    wm.state <- Wm_exited;
    Rwm.River_window_manager_v1.exit_session wm.river_wm_v1;
    Eio.Condition.broadcast wm.shutdown
  | Wm_pending_close ->
    drain_pending_replies wm;
    wm.state <- Wm_close_sent;
    Rwm.River_window_manager_v1.stop wm.river_wm_v1
  | Wm_running | Wm_exited | Wm_close_sent | Wm_closed ->
    Logs.err
    @@ fun m ->
    m
      "got dispatch_pending request for unhandled state: %s"
      (Window_manager_state.to_string wm.state)
;;

let notify_finished (wm : t) =
  match wm.state with
  | Wm_close_sent ->
    wm.state <- Wm_closed;
    Eio.Condition.broadcast wm.shutdown
  | Wm_running ->
    drain_pending_replies wm;
    wm.state <- Wm_closed;
    Eio.Condition.broadcast wm.shutdown
  | Wm_pending_exit _ | Wm_exited | Wm_pending_close | Wm_closed ->
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
  | Wm_closed | Wm_exited -> Some ()
  | Wm_running | Wm_pending_exit _ | Wm_pending_close | Wm_close_sent -> None
;;

let destroy (wm : t) =
  Rwm.River_window_manager_v1.destroy wm.river_wm_v1;
  Xkb.River_xkb_bindings_v1.destroy wm.river_xkb_v1;
  Rlsh.River_layer_shell_v1.destroy wm.river_lsh_v1
;;

let teardown ~(clock : float Eio.Time.clock_ty Eio.Resource.t) (wm : t) =
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
  | Wm_closed -> destroy wm
  | Wm_running | Wm_pending_exit _ | Wm_pending_close | Wm_close_sent ->
    Logs.err
    @@ fun m ->
    m
      "teardown triggered in unexpected state: %s"
      (Window_manager_state.to_string wm.state)
;;
