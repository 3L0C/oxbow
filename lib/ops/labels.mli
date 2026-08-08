(** [window_add wm seat target label] adds [label] to the [target] windows.
    [Error msg] when no window is focused.

    {b Effects:} mutates WM state *)
val window_add
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> string
  -> (Yojson.Safe.t option, string) result

(** [window_remove wm seat target label] removes [label] from the [target]
    windows. [Error msg] when no window is focused.

    {b Effects:} mutates WM state *)
val window_remove
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> string
  -> (Yojson.Safe.t option, string) result

(** [output_add wm seat target label] adds [label] to the [target] outputs.
    [Error msg] when [target] is unresolved.

    {b Effects:} mutates WM state *)
val output_add
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Output.Any.t
  -> string
  -> (Yojson.Safe.t option, string) result

(** [output_remove wm seat target label] removes [label] from the [target]
    outputs.  [Error msg] when [target] is unresolved.

    {b Effects:} mutates WM state *)
val output_remove
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Output.Any.t
  -> string
  -> (Yojson.Safe.t option, string) result
