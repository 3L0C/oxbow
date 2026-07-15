(** [apply ctx window] syncs [window]'s tiled edges and server/client-side
    decoration choice with its presentation and decoration hint.

    {b Effects:} sends River request *)
val apply : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Window.t -> unit
