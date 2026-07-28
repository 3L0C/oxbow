(** [handle_position ~x ~y wm seat] updates [seat]'s position to [x], [y],
    [seat]'s focused output, and [seat]'s cursor target.

    {b Effects:} mutates WM state *)
val handle_position : x:int32 -> y:int32 -> Ocdwm_state.Wm.t -> Ocdwm_state.Seat.t -> unit

(** [warp_target seat] is [Some (x, y)], the center of [seat]'s focused window,
    or [None] if [seat] has no focused window. *)
val warp_target : Ocdwm_state.Seat.t -> (int32 * int32) option

(** [handle wm seat cmd] handles the pointer command, [cmd].

    {b Effects:} mutates WM state *)
val handle
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_ipc.Command.Input.Pointer.t
  -> (Yojson.Safe.t option, string) result
