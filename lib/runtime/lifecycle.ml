open! Ocdwm_state
open! Ocdwm_ops

let sync (ctx : Ctx.manage Ctx.t) =
  let wm = Ctx.wm ctx in
  Focus.layer_shell_sync wm
;;

let request_exit ?(origin = `Local) (wm : Wm.t) =
  match wm.lifecycle with
  | Running ->
    Wm.set_lifecycle wm @@ Pending_exit origin;
    Schedule.manage ()
  | Pending_exit _ | Exited | Close_requested ->
    Logs.warn
    @@ fun m ->
    m
      "ignoring exit request for non-running state: %s"
      (Wm.Lifecycle.to_string wm.lifecycle)
;;

let request_close (wm : Wm.t) =
  match wm.lifecycle with
  | Running ->
    List.iter Seat.clear_pending wm.seats;
    Wm.set_lifecycle wm Close_requested;
    Eio.Condition.broadcast wm.shutdown
  | Pending_exit _ | Exited | Close_requested ->
    Logs.warn
    @@ fun m ->
    m
      "ignoring close request for non-running state: %s"
      (Wm.Lifecycle.to_string wm.lifecycle)
;;

let dispatch_pending (wm : Wm.t) =
  match wm.lifecycle with
  | Pending_exit _ ->
    List.iter Seat.clear_pending wm.seats;
    Wm.set_lifecycle wm Exited;
    Emit.exit_session wm;
    Eio.Condition.broadcast wm.shutdown
  | Running | Exited | Close_requested ->
    Logs.err
    @@ fun m ->
    m
      "got dispatch_pending request for unhandled state: %s"
      (Wm.Lifecycle.to_string wm.lifecycle)
;;

let notify_finished (wm : Wm.t) =
  match wm.lifecycle with
  | Running ->
    List.iter Seat.clear_pending wm.seats;
    Wm.set_lifecycle wm Close_requested;
    Eio.Condition.broadcast wm.shutdown
  | Pending_exit _ | Exited | Close_requested ->
    Logs.err
    @@ fun m ->
    m "got notify_finished for unhandled state: %s" (Wm.Lifecycle.to_string wm.lifecycle)
;;

let await_shutdown (wm : Wm.t) =
  Eio.Condition.loop_no_mutex wm.shutdown
  @@ fun () ->
  match wm.lifecycle with
  | Exited | Close_requested -> Some ()
  | Running | Pending_exit _ -> None
;;

let teardown ~clock (wm : Wm.t) =
  Option.iter Init_script.shutdown wm.init_handle;
  match wm.lifecycle with
  | Exited ->
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
  | Close_requested -> ()
  | Running | Pending_exit _ ->
    Logs.err
    @@ fun m ->
    m "teardown triggered in unexpected state: %s" (Wm.Lifecycle.to_string wm.lifecycle)
;;
