(** [arrange ctx output] grids every window on [output] (all tags, floating and
    maximized included) into a near-square grid over the usable area, gaps and
    borders applied.

    {b Effects:} sends River requests *)
val arrange : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Output.t -> unit

(** [toggle ctx seat] enters or leaves overview on [seat]'s output.  Entering
    exits fullscreen. Leaving views exactly the focused window's tags and
    restores floating and maximized geometry.

    {b Effects:} sends River requests *)
val toggle
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> ('a option, string) result
