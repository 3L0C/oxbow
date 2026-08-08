(** [resolve_one_window wm seat target] is the one window that [target] names.
    [Focused] is the focused window. [Best] is the most recently focused match.
    [Cycle] is the stable-order match after the focused window. Is [Error msg]
    when the pattern fails to compile, when no window matches, or when no window
    is focused. *)
val resolve_one_window
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.One.t
  -> (Oxbow_state.Window.t, string) result

(** [resolve_all_windows wm seat target] is the window list that [target] names.
    [One] is the one resolved window alone. [All] is every match, best first.
    Is [Error msg] if any window pattern fails to compile, matches no window, or
    is not focused. *)
val resolve_all_windows
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> (Oxbow_state.Window.t list, string) result

(** [resolve_one_output wm seat target] is the one output that [target] names.
    [Focused] is the focused output. [Best] is the most recently focused match.
    [Cycle] is the [wm.outputs]-order match after the focused output. Is
    [Error msg] when the pattern fails to compile, when no output matches, or
    when no output is focused. *)
val resolve_one_output
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Output.One.t
  -> (Oxbow_state.Output.t, string) result

(** [resolve_all_outputs wm seat target] is the output list that [target]
    names. [One] is the one resolved output alone. [All] is every match, best
    first. Is [Error msg] if any output pattern fails to compile, matches no
    output, or when no output is focused. *)
val resolve_all_outputs
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Output.Any.t
  -> (Oxbow_state.Output.t list, string) result

(** [transact_all_windows wm seat target ~plan] resolves [target] with
    [resolve_all_windows], runs [plan] on every window, then commits every plan.
    One failed plan aborts the command before any commit. Is the resolved window
    list on success.

    {b Invariants:} The plan must not change state; the commit must not fail. *)
val transact_all_windows
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> plan:(Oxbow_state.Window.t -> (unit -> unit, string) result)
  -> (Oxbow_state.Window.t list, string) result

(** [transact_one_window wm seat target ~plan] is [transact_all_windows] with
    [resolve_one_window]. The plan runs on the one window. Is the resolved
    window on success.

    {b Invariants:} The plan must not change state; the commit must not fail. *)
val transact_one_window
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.One.t
  -> plan:(Oxbow_state.Window.t -> (unit -> unit, string) result)
  -> (Oxbow_state.Window.t, string) result

(** [transact_all_outputs wm seat target ~plan] resolves [target] with
    [resolve_all_outputs], runs [plan] on every output, then commits every plan.
    One failed plan aborts the command before any commit. Is the resolved output
    list on success.

    {b Invariants:} The plan must not change state; the commit must not fail. *)
val transact_all_outputs
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Output.Any.t
  -> plan:(Oxbow_state.Output.t -> (unit -> unit, string) result)
  -> (Oxbow_state.Output.t list, string) result

(** [transact_one_output wm seat target ~plan] is [transact_all_outputs] with
    [resolve_one_output]. The plan runs on the one output. Is the resolved
    output on success.

    {b Invariants:} The plan must not change state; the commit must not fail. *)
val transact_one_output
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Output.One.t
  -> plan:(Oxbow_state.Output.t -> (unit -> unit, string) result)
  -> (Oxbow_state.Output.t, string) result
