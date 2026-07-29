(** [zoom ?warp wm seat] promotes the focused window to the top of the stack if
    it is not already the master. If it is the master, promote and swap with the
    next window. The payload [warp] overrides the warp on focus configuration.
    Is [Error msg] when [seat] has no output or focused window, the focused
    window is not tiled, or no other tiled window exists.

    {b Effects:} mutates WM state *)
val zoom
  :  ?warp:bool
  -> Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result

(** [move_window ?policy window output] removes [window] from its current
    output, if any, and moves it to [output]. No-op when [window] is already
    owned by [output]. If [policy] is not given, [window]'s tags are unchanged.

    {b Effects:} mutates WM state *)
val move_window
  :  ?policy:Ocdwm_core.Tag.Policy.t
  -> Ocdwm_state.Window.t
  -> Ocdwm_state.Output.t
  -> unit

(** [send_window_to_logical wm window dir policy] moves [window] in [dir].
    [window] will be assigned tags according to [policy]. Is [Error msg] when
    [window] has no output, or no other output exists.

    {b Effects:} mutates WM state *)
val send_window_to_logical
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Window.t
  -> Ocdwm_core.Direction.Logical.t
  -> Ocdwm_core.Tag.Policy.t
  -> (Yojson.Safe.t option, string) result

(** [send_window_to_spatial wm window dir policy] moves [window] in [dir].
    [window] will be assigned tags according to [policy]. Is [Error msg] when
    [window] has no output, or no output exists in [dir].

    {b Effects:} mutates WM state *)
val send_window_to_spatial
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Window.t
  -> Ocdwm_core.Direction.Spatial.t
  -> Ocdwm_core.Tag.Policy.t
  -> (Yojson.Safe.t option, string) result

(** [send_window_to_name wm window name policy] moves [window] to the output
    matching [name]. [window] will be assigned tags according to [policy]. Is
    [Error msg] when [window] has no output, or no output named [name] exists.

    {b Effects:} mutates WM state *)
val send_window_to_name
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Window.t
  -> string
  -> Ocdwm_core.Tag.Policy.t
  -> (Yojson.Safe.t option, string) result

(** [send_to_logical wm seat dir policy ~follow] sends [seat]'s focused window
    to the output in logical direction [dir], resolving its tags per [policy].
    When [follow] is [true] focus follows the moved window. Is [Error msg] when
    [window] has no output, or no other output exists.

    {b Effects:} mutates WM state *)
val send_to_logical
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Logical.t
  -> Ocdwm_core.Tag.Policy.t
  -> follow:bool
  -> (Yojson.Safe.t option, string) result

(** [send_to_spatial wm seat dir policy ~follow] sends [seat]'s focused window
    to the output in spatial direction [dir], resolving its tags per [policy].
    When [follow] is [true] focus follows the moved window. Is [Error msg] when
    [window] has no output, or no output exists in [dir].

    {b Effects:} mutates WM state *)
val send_to_spatial
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Spatial.t
  -> Ocdwm_core.Tag.Policy.t
  -> follow:bool
  -> (Yojson.Safe.t option, string) result

(** [send_to_name wm seat name policy ~follow] sends [seat]'s focused window to
    the output named [name], resolving its tags per [policy]. When [follow] is
    [true] focus follows the moved window. Is [Error msg] when [window] has no
    output, or no output named [name] exists.

    {b Effects:} mutates WM state *)
val send_to_name
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> string
  -> Ocdwm_core.Tag.Policy.t
  -> follow:bool
  -> (Yojson.Safe.t option, string) result

(** [toggle_floating seat] toggles [seat]'s focused window between tiled and
    floating. Is [Error msg] when [seat] has no focused window, window has no
    output, or when window is fullscreen, maximized, or fixed.

    {b Effects:} mutates WM state *)
val toggle_floating : Ocdwm_state.Seat.t -> (Yojson.Safe.t option, string) result

(** [maximize wm window] ends any seat operation and maximizes [window].

    {b Effects:} mutates WM state *)
val maximize : Ocdwm_state.Wm.t -> Ocdwm_state.Window.t -> unit

(** [unmaximize window] restores [window] from its maximized state.

    {b Effects:} mutates WM state *)
val unmaximize : Ocdwm_state.Window.t -> unit

(** [fullscreen wm output window cb] makes [window] fullscreen on [output], or
    on its own output when [output] is [None], moving it between outputs when
    needed. Calls [cb] with [Exit_fullscreen] for each fullscreen window visible
    on the target output.

    {b Effects:} mutates WM state *)
val fullscreen
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Output.t option
  -> Ocdwm_state.Window.t
  -> (Ocdwm_state.Wm.t -> Ocdwm_state.Window.t -> Ocdwm_state.Window.Request.t -> unit)
  -> unit

(** [exit_fullscreen window] restores [window] from its fullscreen state. No-op
    when [window] is not fullscreen.

    {b Effects:} mutates WM state *)
val exit_fullscreen : Ocdwm_state.Window.t -> unit

(** [close_focused seat] asks [seat]'s focused window to close. *)
val close_focused : Ocdwm_state.Seat.t -> (Yojson.Safe.t option, string) result

(** [move_to ~x ~y window] moves [window] to the extents [x] and [y]. Is
    [Error msg] when the window is fullscreen.

    {b Effects:} mutates WM state *)
val move_window_to
  :  x:Ocdwm_core.Extent.t
  -> y:Ocdwm_core.Extent.t
  -> Ocdwm_state.Window.t
  -> (Yojson.Safe.t option, string) result

(** [move_to ~x ~y seat] moves [seat]'s focused window to the extents [x] and
    [y]. Is [Error msg] when the window is fullscreen.

    {b Effects:} mutates WM state *)
val move_to
  :  x:Ocdwm_core.Extent.t
  -> y:Ocdwm_core.Extent.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result

(** [move_spatial seat dir by] moves [seat]'s focused window in [dir] by
    [by]. Is [Error msg] when the window is fullscreen.

    {b Effects:} mutates WM state *)
val move_spatial
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Spatial.t
  -> Ocdwm_core.Extent.t
  -> (Yojson.Safe.t option, string) result

(** [resize_window_to ~width ~height window] resizes window to the extents
    [width] and [height]. Is [Error msg] when the window is fullscreen.

    {b Effects:} mutates WM state *)
val resize_window_to
  :  width:Ocdwm_core.Extent.t
  -> height:Ocdwm_core.Extent.t
  -> Ocdwm_state.Window.t
  -> (Yojson.Safe.t option, string) result

(** [resize_to ~width ~height seat] resizes [seat]'s focused window to the
    extents [width] and [height]. Is [Error msg] when the window is fullscreen.

    {b Effects:} mutates WM state *)
val resize_to
  :  width:Ocdwm_core.Extent.t
  -> height:Ocdwm_core.Extent.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result

(** [resize_spatial seat dir by] resizes [seat]'s focused window in [dir] by
    [by]. Is [Error msg] when the window is fullscreen.

    {b Effects:} mutates WM state *)
val resize_spatial
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Spatial.t
  -> Ocdwm_core.Extent.t
  -> (Yojson.Safe.t option, string) result

(** [swap_outputs wm seat ~target ~policy ~follow scope] exchanges the windows
    of two outputs, in both directions. A [Pair] target names the two outputs:
    without names, the two connected outputs swap; with one name, [seat]'s
    output swaps with the named output; with two names, the named pair swaps. A
    [Ring] target swaps the focused output with the next connected ring member,
    or the previous member when [rev] is set. Each window crosses with [policy],
    like a send. When [follow] is [true], focus moves to the window that arrived
    at the head of the focus order of the second output, and the view switches
    to its tags. When no window arrived, focus moves to the second output.
    [scope] controls which windows are swapped. [scope] is one of
    [`Tags | `All | `Visible]. *)
val swap_outputs
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> target:Ocdwm_ipc.Command.Output.Swap.Target.t
  -> policy:Ocdwm_core.Tag.Policy.t
  -> follow:bool
  -> [< `Tags | `All | `Visible ]
  -> (Yojson.Safe.t option, string) result
