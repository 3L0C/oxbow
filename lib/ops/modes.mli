(** [declare wm name] declares mode [name]. Is [Error msg] when [name] is
    already declared.

    {b Effects:} mutates WM state *)
val declare : Ocdwm_state.Wm.t -> string -> (Yojson.Safe.t option, string) result

(** [enter wm seat name] makes [name] [seat]'s current mode; bindings reconcile
    on the next [Seat.sync_bindings]. While the session is locked the change
    takes effect at unlock. Is [Error msg] when [name] is not declared or is
    [Mode.locked].

    {b Effects:} mutates WM state *)
val enter
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> string
  -> (Yojson.Safe.t option, string) result

(** [handle wm seat cmd] handles the mode command, [cmd].

    {b Effects:} mutates WM state *)
val handle
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_ipc.Command.Keymap.Mode.t
  -> (Yojson.Safe.t option, string) result
