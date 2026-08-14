(** [apply_for wm window] applies any configured rules matching [window]. For
    rules of the same effect the last rule wins.

    {b Effects:} mutates WM state *)
val apply_for : Oxbow_state.Wm.t -> Oxbow_state.Window.t -> unit

(** [add wm rule] adds [rule] to [wm]'s configured rules. Merges new [rule] effects
    when an existing rule matches [rule]'s pattern.

    {b Effects:} mutates WM state *)
val add
  :  Oxbow_state.Wm.t
  -> Oxbow_core.Window_rule.t
  -> (Yojson.Safe.t option, string) result

(** [remove wm indices] removes the rules at the given [indices] from [wm]'s
    configured rules. Is [Error msg] when no rule matches.

    {b Effects:} mutates WM state *)
val remove : Oxbow_state.Wm.t -> int list -> (Yojson.Safe.t option, string) result

(** [spawn_for wm window] resolves the spawn position and the focus flag for
    [window]. *)
val spawn_for
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Window.t
  -> Oxbow_core.Spawn_position.t * bool
