(** [apply_for ctx window] applies any configured rules matching [window]. For
    rules of the same effect the last rule wins.

    {b Effects:} mutates WM state; sends River request *)
val apply_for : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Window.t -> unit

(** [add wm rule] appends [rule] to [wm]'s configured rules. Is [Error msg] when
    an equal rule already exists.

    {b Effects:} mutates WM state *)
val add : Ocdwm_state.Wm.t -> Ocdwm_core.Rule.t -> (Yojson.Safe.t option, string) result

(** [remove wm rule] removes the rule equal to [rule] from [wm]'s configured
    rules. Is [Error msg] when no rule matches.

    {b Effects:} mutates WM state *)
val remove
  :  Ocdwm_state.Wm.t
  -> Ocdwm_core.Rule.t
  -> (Yojson.Safe.t option, string) result

(** [handle ctx seat cmd] handles the rule command, [cmd].

    {b Effects:} mutates WM state; sends River request *)
val handle
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_ipc.Command.Rule.t
  -> (Yojson.Safe.t option, string) result
