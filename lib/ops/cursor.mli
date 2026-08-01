(** [handle wm seat cmd] handles [cmd].

    {b Effects:} mutates WM state *)
val handle
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_ipc.Command.Input.Cursor.t
  -> (Yojson.Safe.t option, string) result
