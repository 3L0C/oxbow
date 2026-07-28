(** [handle wm seat cmd] handles the layout command, [cmd].

    {b Effects:} mutates WM state *)
val handle
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_ipc.Command.Layout.t
  -> (Yojson.Safe.t option, string) result
