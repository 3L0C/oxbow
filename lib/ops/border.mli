(** [channels color] splits 8-bit RGBA [color] into four 32-bit channel values
    (r, g, b, a), each byte replicated across its 32 bits. *)
val channels : int32 -> int32 * int32 * int32 * int32

(** [paint ctx] sets border edges, width, and color on every window with an
    output, coloring by urgency and its own output's focused window.

    {b Effects:} sends River request *)
val paint : Ocdwm_state.Ctx.render Ocdwm_state.Ctx.t -> unit
