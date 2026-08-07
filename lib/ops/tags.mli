(** [view seat arg] makes the tags resolved from [arg] the selected tags on
    [seat]'s output. Is [Error msg] when [seat] has no output or when the set
    resolved is empty.

    {b Effects:} mutates WM state *)
val view
  :  Oxbow_state.Seat.t
  -> Oxbow_core.Tag.Arg.t
  -> (Yojson.Safe.t option, string) result

(** [toggle_view seat tags] toggles [tags] within the selected set on [seat]'s
    output. Is [Error msg] when the toggle would leave no tags visible.

    {b Effects:} mutates WM state *)
val toggle_view
  :  Oxbow_state.Seat.t
  -> Oxbow_core.Tag.Set.t
  -> (Yojson.Safe.t option, string) result

(** [view_previous seat] reselects the previous tag set on [seat]'s output. Is
    [Error msg] when no previous set exists.

    {b Effects:} mutates WM state *)
val view_previous : Oxbow_state.Seat.t -> (Yojson.Safe.t option, string) result

(** [view_cycle seat dir] advances the lowest selected tag on [seat]'s output
    one position in [dir], wrapping. Is [Error msg] when [seat] has no output.

    {b Effects:} mutates WM state *)
val view_cycle
  :  Oxbow_state.Seat.t
  -> Oxbow_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [view_cycle_occupied seat dir] moves the selection to the next occupied tag
    in [dir], wrapping. Is [Error msg] when [seat] has no output, or output has
    no occupied tags.

    {b Effects:} mutates WM state *)
val view_cycle_occupied
  :  Oxbow_state.Seat.t
  -> Oxbow_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [tag_window wm seat target ~tags ~follow] assigns [tags] according to
    [target]. When [follow] is [true] focus follows the moved window. Is
    [Error msg] when [target] is unresolved, the set resolves empty, or [tags]
    is [Occupied] and the window has no output.

    {b Effects:} mutates WM state *)
val tag_window
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.t
  -> tags:Oxbow_core.Tag.Arg.t
  -> follow:bool
  -> (Yojson.Safe.t option, string) result

(** [toggle_window_tags wm seat target tags] toggles [tags] on the [target]
    windows. Is [Error msg] when the toggle would leave any [target] window with
    no tags.

    {b Effects:} mutates WM state *)
val toggle_window_tags
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.t
  -> Oxbow_core.Tag.Set.t
  -> (Yojson.Safe.t option, string) result

(** [tag_shift_window wm seat target dir ~follow] advances the [target] windows
    lowest tag one position in [dir], wrapping. When [follow] is [true] focus
    follows the moved window. Is [Error msg] when any [target] window has no
    tags.

    {b Effects:} mutates WM state *)
val tag_shift_window
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.t
  -> Oxbow_core.Direction.Logical.t
  -> follow:bool
  -> (Yojson.Safe.t option, string) result

(** [tag_shift_window_occupied wm seat target dir ~follow] moves the [target]
    windows to the next occupied tag in [dir], wrapping. When [follow] is true
    focus follows the moved window. Is [Error msg] when any [target] window has
    no output, or the output has no occupied tags.

    {b Effects:} mutates WM state *)
val tag_shift_window_occupied
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.t
  -> Oxbow_core.Direction.Logical.t
  -> follow:bool
  -> (Yojson.Safe.t option, string) result
