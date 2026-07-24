(** [handle_position ~x ~y wm seat] updates [seat]'s position to [x], [y],
    [seat]'s focused output, and [seat]'s cursor target.

    {b Effects:} mutates WM state *)
val handle_position : x:int32 -> y:int32 -> Ocdwm_state.Wm.t -> Ocdwm_state.Seat.t -> unit

(** [warp_to_focus ctx seat] warps the pointer to the center of the [seat]'s
    focused window. If the seat has no focused window, the pointer warps to the
    center of its focused output instead.

    {b Effects:} sends River request *)
val warp_to_focus : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Seat.t -> unit

(** [handle ctx seat cmd] handles the pointer command, [cmd].

    {b Effects:} mutates WM state; sends River request *)
val handle
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_ipc.Command.Input.Pointer.t
  -> (Yojson.Safe.t option, string) result
