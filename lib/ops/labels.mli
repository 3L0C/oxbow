(** [window_add wm seat target label] adds [label] to the [target] windows.
    [Error msg] when no window is focused.

    {b Effects:} mutates WM state *)
val window_add
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.t
  -> string
  -> (Yojson.Safe.t option, string) result

(** [window_remove wm seat target label] removes [label] from the [target]
    windows. [Error msg] when no window is focused.

    {b Effects:} mutates WM state *)
val window_remove
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.t
  -> string
  -> (Yojson.Safe.t option, string) result

(** [output_add seat label] adds [label] to the focused output of [seat]. Error
    when no output is focused.

    {b Effects:} mutates WM state *)
val output_add : Oxbow_state.Seat.t -> string -> (Yojson.Safe.t option, string) result

(** [output_remove seat label] removes [label] from the focused output of
    [seat]. Error when no output is focused.

    {b Effects:} mutates WM state *)
val output_remove : Oxbow_state.Seat.t -> string -> (Yojson.Safe.t option, string) result
