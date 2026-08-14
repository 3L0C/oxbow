(** [apply_rules_to wm device] applies [wm]'s input rules matching [device].

    {b Effects:} mutates WM state *)
val apply_rules_to : Oxbow_state.Wm.t -> Oxbow_state.Input_device.t -> unit

(** [add wm rule] adds [rule] to [wm]'s input rules if it is novel, or merges
    with the existing rule, overwriting existing, non-empty, settings.

    {b Effects:} mutates WM state *)
val add
  :  Oxbow_state.Wm.t
  -> Oxbow_core.Input_rule.t
  -> (Yojson.Safe.t option, string) result

(** [remove wm indices] removes the rules at the given [indices] from [wm]'s
    input rule list.

    {b Effects:} mutates WM state *)
val remove : Oxbow_state.Wm.t -> int list -> (Yojson.Safe.t option, string) result

(** [apply_rule wm rule] applies [rule] to the matching input devices.

    {b Effects:} mutates WM state *)
val apply_rule
  :  Oxbow_state.Wm.t
  -> Oxbow_core.Input_rule.t
  -> (Yojson.Safe.t option, string) result
