(** [handle_position wm seat (x, y)] updates [seat]'s position to [(x, y)],
    [seat]'s focused output, and [seat]'s cursor target. Will focus the window
    under [(x, y)] when [seat]'s position changed.

    {b Effects:} mutates WM state *)
val handle_position : Oxbow_state.Wm.t -> Oxbow_state.Seat.t -> int32 * int32 -> unit

(** [warp_target seat] is [Some (x, y)], the center of [seat]'s focused window,
    or [None] if [seat] has no focused window. *)
val warp_target : Oxbow_state.Seat.t -> (int32 * int32) option

(** [handle wm seat cmd] handles the pointer command, [cmd].

    {b Effects:} mutates WM state *)
val handle
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_ipc.Command.Input.Pointer.t
  -> (Yojson.Safe.t option, string) result
