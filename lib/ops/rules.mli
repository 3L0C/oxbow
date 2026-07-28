(** [apply_for wm window] applies any configured rules matching [window]. For
    rules of the same effect the last rule wins.

    {b Effects:} mutates WM state *)
val apply_for : Ocdwm_state.Wm.t -> Ocdwm_state.Window.t -> unit

(** [add wm rule] adds [rule] to [wm]'s configured rules. Merges new [rule] effects
    when an existing rule matches [rule]'s pattern.

    {b Effects:} mutates WM state *)
val add : Ocdwm_state.Wm.t -> Ocdwm_core.Rule.t -> (Yojson.Safe.t option, string) result

(** [remove wm pattern] removes the rule matching [pattern] from [wm]'s
    configured rules. Is [Error msg] when no rule matches.

    {b Effects:} mutates WM state *)
val remove
  :  Ocdwm_state.Wm.t
  -> Ocdwm_core.Pattern.t
  -> (Yojson.Safe.t option, string) result

(** [handle wm seat cmd] handles the rule command, [cmd].

    {b Effects:} mutates WM state *)
val handle
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_ipc.Command.Rule.t
  -> (Yojson.Safe.t option, string) result
