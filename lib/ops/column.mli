(** [consume seat] merges the next column into the focused column. Is
    [Error msg] when [seat] has no output, no window is focused, or no next
    column exists.

    {b Effects:} mutates WM state *)
val consume : Ocdwm_state.Seat.t -> (Yojson.Safe.t option, string) result

(** [release seat] expels the focused window into its own column, immediately
    left of its former column. Is [Error msg] when [seat] has no output, no
    window is focused, or the focused window is alone in its column.

    {b Effects:} mutates WM state *)
val release : Ocdwm_state.Seat.t -> (Yojson.Safe.t option, string) result

(** [move seat dir] hops the focused column over the adjacent column in [dir].
    The hop wraps at the strip ends. Is [Error msg] when [seat] has no output,
    no window is focused, or no other column exists.

    {b Effects:} mutates WM state *)
val move
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [set_width seat delta] applies [delta] to the width factor of the focused
    column. A relative delta applies to the current effective factor. Is
    [Error msg] when [seat] has no output or no window is focused.

    {b Effects:} mutates WM state *)
val set_width
  :  Ocdwm_state.Seat.t
  -> float Ocdwm_core.Delta.t
  -> (Yojson.Safe.t option, string) result

(** [default_width seat] clears the width override of the focused column; the
    column tracks [mfact] again. Is [Error msg] when [seat] has no output or no
    window is focused.

    {b Effects:} mutates WM state *)
val default_width : Ocdwm_state.Seat.t -> (Yojson.Safe.t option, string) result

(** [cycle_width seat] moves the width factor of the focused column to the next
    preset, with wrap. Is [Error msg] when [seat] has no output or no window is
    focused.

    {b Effects:} mutates WM state *)
val cycle_width : Ocdwm_state.Seat.t -> (Yojson.Safe.t option, string) result

(** [zoom ?warp ctx seat] promotes the focused window in the scrolling layout. A
    window in a shared column gets its own column at the front. A solo column
    moves to the front. A solo front column swaps its window with the head of
    the next column, and the two consume flags swap with them. The payload
    [warp] overrides the warp on focus configuration.

    {b Effects:} mutates WM state; marks dirty; sends River request *)
val zoom
  :  ?warp:bool
  -> Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result
