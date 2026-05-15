type t = Types.Window_manager.t

(** [set_focused_output wm output] sets [output] as the focused output for the
    window manager.

    {b Effects:} mutates WM state *)
val set_focused_output : t -> Types.Output.t option -> unit

(** [focus_output ctx output] sets [output] as the focused output and syncs with
    River.

   {b Effects:} mutates WM state; sends River request *)
val focus_output : Ctx.manage Ctx.t -> Types.Output.t option -> unit

(** [sync ctx] syncs ocdwm and River state.

    {b Effects:} mutates WM state; sends River request *)
val sync : Ctx.manage Ctx.t -> unit

(** [mark_dirty wm] triggers a manage sequence.

   {b Effects:} mutates WM state; sends River request *)
val mark_dirty : t -> unit

(** [request_exit ?origin wm] indicates a request to end the session made by the
    user, a process signal, or River itself. No-op when [wm.state <>
    Wm_running].

   {b Effects:} mutates WM state *)
val request_exit : ?origin:[ `Local | `Compositor ] -> t -> unit

(** [request_close wm] is a request to close ocdwm but not River. No-op when
    [wm.state <> Wm_running].

   {b Effects:} mutates WM state; sends River request *)
val request_close : t -> unit

(** [dispatch_pending wm] handles the pending exit/close state for [wm].

   {b Effects:} mutates WM state; sends River request *)
val dispatch_pending : t -> unit

(** [notify_finished wm] broadcast ocdwm is closing.

   {b Effects:} mutates WM state *)
val notify_finished : t -> unit

(** [await_shutdown wm] blocks the current fiber until [request_shutdown] has
    been called. Returns immediately if shutdown is already in progress.

   {b Effects:} mutates WM state *)
val await_shutdown : t -> unit

(** [teardown ~clock wm] handles [wm] cleanup.

   {b Effects:} mutates WM state *)
val teardown : clock:float Eio.Time.clock_ty Eio.Resource.t -> t -> unit
