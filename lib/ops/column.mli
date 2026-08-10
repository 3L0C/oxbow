(** [consume wm seat target] merges the next column into the column of the
    [target] window. Is [Error msg] when the [target] window no output, or no
    next column exists.

    {b Effects:} mutates WM state *)
val consume
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.One.t
  -> (Yojson.Safe.t option, string) result

(** [release wm seat target] expels the [target] window into its own column,
    immediately left of its former column. Is [Error msg] when the [target]
    window has no output, or the target window is alone in its column.

    {b Effects:} mutates WM state *)
val release
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.One.t
  -> (Yojson.Safe.t option, string) result

(** [detach window] expels [window] into its own column and clears the consume
    bits, with the same logic as [release]. No-op when the layout is not
    scrolling, [window] is not in the strip, or [window] is alone in its column.

    {b Effects:} mutates WM state *)
val detach : Oxbow_state.Window.t -> unit

(** [move wm seat target dir] hops the column of the [target] window over the
    adjacent column in [dir]. The hop wraps at the strip ends. Is [Error msg]
    when the [target] window has no output, or no other column exists.

    {b Effects:} mutates WM state *)
val move
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.One.t
  -> Oxbow_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [set_width wm seat target delta ~global] applies [delta] to the width factor
    of the column of the [target] window. Applies to all columns when [global]
    is [true]. A relative delta applies to the current effective factor. Is
    [Error msg] when the [target] window has no output.

    {b Effects:} mutates WM state *)
val set_width
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.One.t
  -> float Oxbow_core.Delta.t
  -> global:bool
  -> (Yojson.Safe.t option, string) result

(** [default_width wm seat target] clears the width override of the column of
    the [target] window. Is [Error msg] when the [target] window has no output.

    {b Effects:} mutates WM state *)
val default_width
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.One.t
  -> (Yojson.Safe.t option, string) result

(** [cycle_width wm seat target] moves the width factor of the column of the
    [target] window to the next preset, with wrap. Is [Error msg] when the
    [target] window has no output.

    {b Effects:} mutates WM state *)
val cycle_width
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.One.t
  -> (Yojson.Safe.t option, string) result

(** [zoom ?warp wm seat window] promotes [window] in the scrolling layout. A
    window in a shared column gets its own column at the front. A solo column
    moves to the front. A solo front column swaps its window with the head of
    the next column, and the two consume flags swap with them. The payload
    [warp] overrides the warp on focus configuration.

    {b Effects:} mutates WM state *)
val zoom
  :  ?warp:bool
  -> Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_state.Window.t
  -> (Yojson.Safe.t option, string) result
