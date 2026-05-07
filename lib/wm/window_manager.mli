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

(** [request_shutdown ?origin wm] set's [shutdown_origin] (default [`Local]) on
    first call and broadcasts {!shutdown}. Subsequent calls re-broadcast. Safe
    to call from a signal handler - performs only [Eio.Condition.broadcast].

   {b Effects:} mutates WM state *)
val request_shutdown : ?origin:[ `Local | `Compositor ] -> t -> unit

(** [await_shutdown wm] blocks the current fiber until [request_shutdown] has
    been called. Returns immediately if shutdown is already in progress.

   {b Effects:} mutates WM state *)
val await_shutdown : t -> unit
