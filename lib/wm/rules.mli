(** [apply_for ctx window] applies the [wm.config.rules] matching [window]. The last
    rule wins

    {b Effects:} mutates WM state; sends River request *)
val apply_for : Ctx.manage Ctx.t -> Types.Window.t -> unit
