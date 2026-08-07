(** [resolve_all_windows wm seat target] is the [target] window list. [Focused]
    is the focused window alone. [Best] is the most recently focused match
    alone. [All] is every match, best first. [Cycle] is the stable-order match
    after the focused window, alone. Is [Error msg] when the pattern fails to
    compile, when no window matches, or when no window is focused. *)
val resolve_all_windows
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.t
  -> (Oxbow_state.Window.t list, string) result

(** [resolve_one_window wm seat target] is [resolve_all_windows] for a command
    that acts on one window. Is [Error msg] when [target] selects [All]. *)
val resolve_one_window
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.t
  -> (Oxbow_state.Window.t, string) result

(** [transact_all_windows wm seat target ~plan] resolves [target] with
    [resolve_all_windows], runs [plan] on every window, then commits the planned
    changes. One failed plan aborts the command before any commit. Is the
    resolved window list on success.

    {b Invariants:} The plan must not change state; the commit must not fail. *)
val transact_all_windows
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.t
  -> plan:(Oxbow_state.Window.t -> (unit -> unit, string) result)
  -> (Oxbow_state.Window.t list, string) result

(** [transact_one_window wm seat target ~plan] is [transact_all_windows] with
    [resolve_one_window]. [plan] runs on one window. *)
val transact_one_window
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.t
  -> plan:(Oxbow_state.Window.t -> (unit -> unit, string) result)
  -> (Oxbow_state.Window.t, string) result
