type t = Types.Window_manager.t

(** [mark_dirty wm] triggers a manage sequence.

    {b Effects:} mutates WM state; sends River request *)
val mark_dirty : t -> unit

(** [request_focus_output wm seat output] updates [seat]'s focused output and
    marks the WM dirty so that a manage cycle re-syncs derived state. No-op if
    the value is unchanged.

    {b Effects:} mutates WM state; sends River request *)
val request_focus_output : t -> Types.Seat.t -> Types.Output.t option -> unit

(** [focused_output wm] is the focused output on [wm]'s primary seat, or [None] if
    no primary seat is defined or no focused output is defined for the seat. *)
val focused_output : t -> Types.Output.t option

(** [default_output wm] is the preferred default output: the focused output if
    any, else the head of [wm.outputs], else [None]. *)
val default_output : t -> Types.Output.t option

(** [ensure_seat_output wm seat] assigns [default_output wm] to [seat] if it has
    no current output. No-op if [seat] already has an output, or if no outputs
    exist.

    {b Effects:} mutates WM state *)
val ensure_seat_output : t -> Types.Seat.t -> unit

(** [focus_output ctx seat output] updates the output of [seat] and sends the necessary
    layer shell requests.

    {b Effects:} mutates WM state; sends River request *)
val focus_output : Ctx.manage Ctx.t -> Types.Seat.t -> Types.Output.t option -> unit

(** [sync ctx] syncs ocdwm and River state.

    {b Effects:} mutates WM state; sends River request *)
val sync : Ctx.manage Ctx.t -> unit

(** [request_exit ?origin wm] indicates a request to end the session made by the
    user, a process signal, or River itself. No-op when [wm.state <>
    Wm_running].

    {b Effects:} mutates WM state *)
val request_exit : ?origin:[ `Local | `Compositor ] -> t -> unit

(** [request_close wm] is a request to close ocdwm but not River. No-op when
    [wm.state <> Wm_running].

    {b Effects:} mutates WM state *)
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
