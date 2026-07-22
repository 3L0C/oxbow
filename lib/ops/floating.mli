(** [arrange ctx output] floats every tag-visible tiled window on [output].
    No-op when a visible window is fullscreen.

    {b Effects:} mutates WM state; sends River request *)
val arrange : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Output.t -> unit
