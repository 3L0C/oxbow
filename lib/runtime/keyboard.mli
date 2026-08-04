(** [handle ctx seat cmd] handles [cmd].

    {b Effects:} mutates WM state *)
val handle
  :  Ctx.manage Ctx.t
  -> Oxbow_state.Seat.t
  -> Oxbow_ipc.Command.Input.Keyboard.t
  -> (Yojson.Safe.t option, string) result
