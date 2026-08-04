(** [apply wm device] applies [wm]'s input rules matching [device].

    {b Effects:} mutates WM state *)
val apply : Oxbow_state.Wm.t -> Oxbow_state.Input_device.t -> unit

(** [add wm rule] adds [rule] to [wm]'s input rules if it is novel, or merges
    with the existing rule, overwriting existing, non-empty, settings.

    {b Effects:} mutates WM state *)
val add
  :  Oxbow_state.Wm.t
  -> Oxbow_core.Input_rule.t
  -> (Yojson.Safe.t option, string) result

(** [remove wm index] removes the [wm]'s input rule at [index].

    {b Effects:} mutates WM state *)
val remove : Oxbow_state.Wm.t -> int -> (Yojson.Safe.t option, string) result
