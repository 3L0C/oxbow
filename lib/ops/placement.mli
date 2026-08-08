(** [zoom ?warp wm seat target] promotes the window [target] to the top of the
    stack if it is not already the master. If it is the master, promote and swap
    with the next window. [warp] overrides the warp on focus configuration. Is
    [Error msg] when window has no output, is not tiled, or no other tiled
    window exists.

    {b Effects:} mutates WM state *)
val zoom
  :  ?warp:bool
  -> Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.One.t
  -> (Yojson.Safe.t option, string) result

(** [move_window ?policy window output] removes [window] from its current
    output, if any, and moves it to [output]. No-op when [window] is already
    owned by [output]. If [policy] is not given, [window]'s tags are unchanged.

    {b Effects:} mutates WM state *)
val move_window
  :  ?policy:Oxbow_core.Tag.Policy.t
  -> Oxbow_state.Window.t
  -> Oxbow_state.Output.t
  -> unit

(** [send_window_to_logical wm window dir policy] moves [window] in [dir].
    [window] will be assigned tags according to [policy]. Is [Error msg] when
    [window] has no output, or no other output exists.

    {b Effects:} mutates WM state *)
val send_window_to_logical
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Window.t
  -> Oxbow_core.Direction.Logical.t
  -> Oxbow_core.Tag.Policy.t
  -> (Yojson.Safe.t option, string) result

(** [send_window_to_spatial wm window dir policy] moves the window [window] in
    [dir]. [window] will be assigned tags according to [policy]. Is [Error msg]
    when [window] has no output, or no output exists in [dir].

    {b Effects:} mutates WM state *)
val send_window_to_spatial
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Window.t
  -> Oxbow_core.Direction.Spatial.t
  -> Oxbow_core.Tag.Policy.t
  -> (Yojson.Safe.t option, string) result

(** [send_window_to_name wm window name policy] moves the window [window] to the
    output matching [name]. [window] will be assigned tags according to
    [policy]. Is [Error msg] when [window] has no output, or no output named
    [name] exists.

    {b Effects:} mutates WM state *)
val send_window_to_name
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Window.t
  -> string
  -> Oxbow_core.Tag.Policy.t
  -> (Yojson.Safe.t option, string) result

(** [send_to_logical wm seat target dir policy ~follow] sends the [target]
    windows to the output in logical direction [dir], resolving its tags per
    [policy]. When [follow] is [true] focus follows the moved window. Is
    [Error msg] when any [target] window has no output, or no other output exists.

    {b Effects:} mutates WM state *)
val send_to_logical
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> Oxbow_core.Direction.Logical.t
  -> Oxbow_core.Tag.Policy.t
  -> follow:bool
  -> (Yojson.Safe.t option, string) result

(** [send_to_spatial wm seat target dir policy ~follow] sends the [target]
    windows to the output in spatial direction [dir], resolving its tags per
    [policy]. When [follow] is [true] focus follows the moved window. Is
    [Error msg] when any [target] window has no output, or no output exists in
    [dir].

    {b Effects:} mutates WM state *)
val send_to_spatial
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> Oxbow_core.Direction.Spatial.t
  -> Oxbow_core.Tag.Policy.t
  -> follow:bool
  -> (Yojson.Safe.t option, string) result

(** [send_to_name wm seat target name policy ~follow] sends the [target] windows
    to the output named [name], resolving its tags per [policy]. When [follow]
    is [true] focus follows the moved window. Is [Error msg] when any [target]
    window has no output, or no output named [name] exists.

    {b Effects:} mutates WM state *)
val send_to_name
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> string
  -> Oxbow_core.Tag.Policy.t
  -> follow:bool
  -> (Yojson.Safe.t option, string) result

(** [toggle_floating wm seat target] toggles the [target] windows between tiled
    and floating. Is [Error msg] when a target window has no output, or when
    window is fullscreen, maximized, or fixed.

    {b Effects:} mutates WM state *)
val toggle_floating
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> (Yojson.Safe.t option, string) result

(** [maximize wm window] ends any seat operation and maximizes [window].

    {b Effects:} mutates WM state *)
val maximize : Oxbow_state.Wm.t -> Oxbow_state.Window.t -> unit

(** [unmaximize window] restores [window] from its maximized state.

    {b Effects:} mutates WM state *)
val unmaximize : Oxbow_state.Window.t -> unit

(** [fullscreen wm output window cb] makes [window] fullscreen on [output], or
    on its own output when [output] is [None], moving it between outputs when
    needed. Calls [cb] with [Exit_fullscreen] for each fullscreen window visible
    on the target output.

    {b Effects:} mutates WM state *)
val fullscreen
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Output.t option
  -> Oxbow_state.Window.t
  -> (Oxbow_state.Wm.t -> Oxbow_state.Window.t -> Oxbow_state.Window.Request.t -> unit)
  -> unit

(** [exit_fullscreen window] restores [window] from its fullscreen state. No-op
    when [window] is not fullscreen.

    {b Effects:} mutates WM state *)
val exit_fullscreen : Oxbow_state.Window.t -> unit

(** [close wm seat target] requests close on the [target] windows. *)
val close
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> (Yojson.Safe.t option, string) result

(** [move_to ~x ~y window] moves [window] to the extents [x] and [y]. Is
    [Error msg] when the window is fullscreen.

    {b Effects:} mutates WM state *)
val move_window_to
  :  x:Oxbow_core.Extent.t
  -> y:Oxbow_core.Extent.t
  -> Oxbow_state.Window.t
  -> (Yojson.Safe.t option, string) result

(** [move_to ~x ~y wm seat target] moves the [target] windows to the extents [x]
    and [y]. Is [Error msg] when the any [target] window is fullscreen.

    {b Effects:} mutates WM state *)
val move_to
  :  x:Oxbow_core.Extent.t
  -> y:Oxbow_core.Extent.t
  -> Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> (Yojson.Safe.t option, string) result

(** [move_spatial wm seat target dir by] moves the [target] windows in [dir] by
    [by]. Is [Error msg] when the any [target] window is fullscreen.

    {b Effects:} mutates WM state *)
val move_spatial
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> Oxbow_core.Direction.Spatial.t
  -> Oxbow_core.Extent.t
  -> (Yojson.Safe.t option, string) result

(** [resize_window_to ~width ~height window] resizes window to the extents
    [width] and [height]. Is [Error msg] when the window is fullscreen.

    {b Effects:} mutates WM state *)
val resize_window_to
  :  width:Oxbow_core.Extent.t
  -> height:Oxbow_core.Extent.t
  -> Oxbow_state.Window.t
  -> (Yojson.Safe.t option, string) result

(** [resize_to ~width ~height wm seat target] resizes the [target] windows to
    the extents [width] and [height]. Is [Error msg] when any [target] window is
    fullscreen.

    {b Effects:} mutates WM state *)
val resize_to
  :  width:Oxbow_core.Extent.t
  -> height:Oxbow_core.Extent.t
  -> Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> (Yojson.Safe.t option, string) result

(** [resize_spatial wm seat target dir by] resizes the [target] windows in [dir]
    by [by]. Is [Error msg] when any [target] window is fullscreen.

    {b Effects:} mutates WM state *)
val resize_spatial
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> Oxbow_core.Direction.Spatial.t
  -> Oxbow_core.Extent.t
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
    [`Tags | `All | `Visible].

    {b Effects:} mutates WM state *)
val swap_outputs
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> target:Oxbow_ipc.Command.Output.Swap.Target.t
  -> policy:Oxbow_core.Tag.Policy.t
  -> follow:bool
  -> [< `Tags | `All | `Visible ]
  -> (Yojson.Safe.t option, string) result

(** [set_sticky wm seat target scope] sets the sticky scope of the [target]
    windows. Is [Error msg] when no windows match [target].

    {b Effects:} mutates WM state *)
val set_sticky
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> Oxbow_core.Sticky.t
  -> (Yojson.Safe.t option, string) result

(** [toggle_sticky wm seat target toggle] sets the [target] windows to [toggle]
    when it is [Off], and [Off] otherwise. Is [Error msg] when no windows match
    [target].

    {b Effects:} mutates WM state *)
val toggle_sticky
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> Oxbow_core.Sticky.Toggle.t
  -> (Yojson.Safe.t option, string) result
