(** [handle wm seat cmd] handles [cmd].

    {b Effects:} mutates WM state *)
val handle
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_ipc.Command.Keymap.Mode.t
  -> (Yojson.Safe.t option, string) result
