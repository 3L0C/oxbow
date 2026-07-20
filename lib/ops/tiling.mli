(** [arrange ctx output] tiles all non-floating windows on [output] according to
    [output]'s currently viewed tags. Is a no-op if [output] is displaying a
    fullscreen window.

    {b Effects:} mutates WM state; sends River request *)
val arrange : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Output.t -> unit
