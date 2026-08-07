(** [resolve_windows wm seat target] is the window list that [target] names,
    best match first. Best match is focus recency. [None] is the focused window
    alone.  Without [all], the list holds the best match alone. Is [Error msg]
    when the pattern fails to compile, when no window matches, or when no window
    is focused. *)
val resolve_windows
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.t
  -> (Oxbow_state.Window.t list, string) result

(** [transact wm seat target ~plan] resolves [target], runs [plan] on every
    window, then commits. No commit if any plan fails. Is the resolved window
    list on success.

    {b Invariants:} The plan must not change state; the commit must not fail. *)
val transact_windows
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.t
  -> plan:(Oxbow_state.Window.t -> (unit -> unit, string) result)
  -> (Oxbow_state.Window.t list, string) result
