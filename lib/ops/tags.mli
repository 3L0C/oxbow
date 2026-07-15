(** [view seat arg] makes the tags resolved from [arg] the selected tags on
    [seat]'s output. Is [Error _] when [seat] has no output or when the set
    resolved is empty.

    {b Effects:} mutates WM state *)
val view
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Tag.Arg.t
  -> (Yojson.Safe.t option, string) result

(** [toggle_view seat tags] toggles [tags] within the selected set on [seat]'s
    output. Is [Error _] when the toggle would leave no tags visible.

    {b Effects:} mutates WM state *)
val toggle_view
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Tag.Set.t
  -> (Yojson.Safe.t option, string) result

(** [view_previous seat] reselects the previous tag set on [seat]'s output. Is
    [Error _] when no previous set exists.

    {b Effects:} mutates WM state *)
val view_previous : Ocdwm_state.Seat.t -> (Yojson.Safe.t option, string) result

(** [view_cycle seat dir] advances the lowest selected tag on [seat]'s output
    one position in [dir], wrapping. Is [Error _] when [seat] has no output.

    {b Effects:} mutates WM state *)
val view_cycle
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [view_cycle_occupied seat dir] moves the selection to the next occupied tag
    in [dir], wrapping. Is [Error _] when [seat] has no output.

    {b Effects:} mutates WM state *)
val view_cycle_occupied
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [tag_window seat arg] assigns the tags resolved from [arg] to [seat]'s
    focused window. Is [Error _] when there is no focused window, the set
    resolves empty, or [arg] is [Occupied] and the window has no output.

    {b Effects:} mutates WM state *)
val tag_window
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Tag.Arg.t
  -> (Yojson.Safe.t option, string) result

(** [toggle_window_tags seat tags] toggles [tags] on [seat]'s focused window.
    Is [Error _] when the toggle would leave the window on no tags.

    {b Effects:} mutates WM state *)
val toggle_window_tags
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Tag.Set.t
  -> (Yojson.Safe.t option, string) result
