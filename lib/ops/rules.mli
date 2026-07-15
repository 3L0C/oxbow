(** [apply_for ctx window] applies any configured rules matching [window]. For
    rules of the same effect the last rule wins.

    {b Effects:} mutates WM state; sends River request *)
val apply_for : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Window.t -> unit
