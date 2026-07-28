(** [request_exit ?origin wm] indicates a request to end the session made by the
    user, a process signal, or River itself. No-op when [wm] is not [Running].

    {b Effects:} mutates WM state *)
val request_exit : ?origin:[ `Local | `Compositor ] -> Ocdwm_state.Wm.t -> unit

(** [request_close wm] is a request to close ocdwm but not River. No-op when
    [wm] is not [Running].

    {b Effects:} mutates WM state *)
val request_close : Ocdwm_state.Wm.t -> unit

(** [dispatch_pending wm] handles the pending exit/close state for [wm].

    {b Effects:} mutates WM state *)
val dispatch_pending : Ocdwm_state.Wm.t -> unit

(** [notify_finished wm] broadcast ocdwm is closing.

    {b Effects:} mutates WM state *)
val notify_finished : Ocdwm_state.Wm.t -> unit

(** [await_shutdown wm] blocks the current fiber until [request_shutdown] has
    been called. No-op if shutdown is already in progress.

    {b Effects:} mutates WM state *)
val await_shutdown : Ocdwm_state.Wm.t -> unit

(** [teardown ~clock wm] handles [wm] cleanup.

    {b Effects:} mutates WM state *)
val teardown
  :  clock:[> float Eio.Time.clock_ty ] Eio.Resource.t
  -> Ocdwm_state.Wm.t
  -> unit
