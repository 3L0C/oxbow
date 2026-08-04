(** [handle wm seat cmd] handles the layout command, [cmd].

    {b Effects:} mutates WM state *)
val handle
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_ipc.Command.Layout.t
  -> (Yojson.Safe.t option, string) result
