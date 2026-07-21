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
