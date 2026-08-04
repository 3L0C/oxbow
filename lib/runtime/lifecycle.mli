(** [request_exit ?origin wm] indicates a request to end the session made by the
    user, a process signal, or River itself. No-op when [wm] is not [Running].

    {b Effects:} mutates WM state *)
val request_exit : ?origin:[ `Local | `Compositor ] -> Oxbow_state.Wm.t -> unit

(** [request_close wm] is a request to close oxbow but not River. No-op when
    [wm] is not [Running].

    {b Effects:} mutates WM state *)
val request_close : Oxbow_state.Wm.t -> unit

(** [dispatch_pending wm] handles the pending exit/close state for [wm].

    {b Effects:} mutates WM state *)
val dispatch_pending : Oxbow_state.Wm.t -> unit

(** [notify_finished wm] broadcast oxbow is closing.

    {b Effects:} mutates WM state *)
val notify_finished : Oxbow_state.Wm.t -> unit

(** [await_shutdown wm] blocks the current fiber until [request_shutdown] has
    been called. No-op if shutdown is already in progress.

    {b Effects:} mutates WM state *)
val await_shutdown : Oxbow_state.Wm.t -> unit

(** [teardown ~clock wm] handles [wm] cleanup.

    {b Effects:} mutates WM state *)
val teardown
  :  clock:[> float Eio.Time.clock_ty ] Eio.Resource.t
  -> Oxbow_state.Wm.t
  -> unit
