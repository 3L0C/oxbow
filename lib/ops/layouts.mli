(** [handle ctx seat cmd] handles the layout command, [cmd].

    {b Effects:} mutates WM state; sends River request *)
val handle
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_ipc.Command.Layout.t
  -> (Yojson.Safe.t option, string) result
