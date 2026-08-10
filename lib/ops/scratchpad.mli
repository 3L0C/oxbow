(** [set wm seat target name] sets the [target] windows scratchpad group to
    [name].

    {b Effects:} mutates WM state *)
val set
  :  Oxbow_state.Types.Wm.t
  -> Oxbow_state.Types.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> string option
  -> (Yojson.Safe.t option, string) result

(** [clear wm seat target] clears the [target] windows scratchpad group and
    stashes the windows.

    {b Effects:} mutates WM state *)
val clear
  :  Oxbow_state.Types.Wm.t
  -> Oxbow_state.Types.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> (Yojson.Safe.t option, string) result

(** [toggle wm seat name] displays, or hides the scratchpads matching [name] on
    [seat]'s focused output. Is [Error msg] if no scratchpad matches [name] or
    [seat] has no focused output.

    {b Effects:} mutate WM state *)
val toggle
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> string
  -> (Yojson.Safe.t option, string) result
