(** [handle ctx seat cmd] handles [cmd].

    {b Effects:} mutates WM state *)
val handle
  :  Ctx.manage Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_ipc.Command.Input.Keyboard.t
  -> (Yojson.Safe.t option, string) result
