(** [paint ctx seat] sets border edges, width, and color on every window with an
    output, coloring by urgency and its own output's focused window.

    {b Effects:} sends River request *)
val paint : Ocdwm_state.Ctx.render Ocdwm_state.Ctx.t -> Ocdwm_state.Seat.t -> unit
