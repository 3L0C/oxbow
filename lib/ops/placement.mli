(** [zoom ctx seat] promotes the focused window to the top of the stack if it is
    not already the master. If it is the master, promote and swap with the  next
    window.

    {b Effects:} mutates WM state; sends River request *)
val zoom : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Seat.t -> unit

(** [move_window ?policy window output] removes [window] from its current output,
    if any, and moves it to [output]. No-op when [window] is already owned by
    [output]. If [policy] is not given, [window]'s tags are unchanged.

    {b Effects:} mutates WM state *)
val move_window
  :  ?policy:Ocdwm_core.Tag.Policy.t
  -> Ocdwm_state.Window.t
  -> Ocdwm_state.Output.t
  -> unit

(** [send_window_to_logical ctx window dir policy] moves [window] in [dir]. [window]
    will be assigned tags according to [policy].

    {b Effects:} mutates WM state; sends River request *)
val send_window_to_logical
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Window.t
  -> Ocdwm_core.Direction.Logical.t
  -> Ocdwm_core.Tag.Policy.t
  -> unit

(** [send_window_to_spatial ctx window dir policy] moves [window] in [dir]. [window]
    will be assigned tags according to [policy].

    {b Effects:} mutates WM state; sends River request *)
val send_window_to_spatial
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Window.t
  -> Ocdwm_core.Direction.Spatial.t
  -> Ocdwm_core.Tag.Policy.t
  -> unit

(** [send_window_to_name ctx window name policy] moves [window] to the output matching
    [name]. [window] will be assigned tags according to [policy].

    {b Effects:} mutates WM state; sends River request *)
val send_window_to_name
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Window.t
  -> string
  -> Ocdwm_core.Tag.Policy.t
  -> unit

(** [send_to_logical ctx seat dir policy] sends [seat]'s focused window to the
    output in logical direction [dir], resolving its tags per [policy].

    {b Effects:} mutates WM state; sends River request *)
val send_to_logical
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Logical.t
  -> Ocdwm_core.Tag.Policy.t
  -> (Yojson.Safe.t option, string) result

(** [send_to_spatial ctx seat dir policy] sends [seat]'s focused window to the
    output in spatial direction [dir], resolving its tags per [policy].

    {b Effects:} mutates WM state; sends River request *)
val send_to_spatial
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Spatial.t
  -> Ocdwm_core.Tag.Policy.t
  -> (Yojson.Safe.t option, string) result

(** [send_to_name ctx seat name policy] sends [seat]'s focused window to the
    output named [name], resolving its tags per [policy].

    {b Effects:} mutates WM state; sends River request *)
val send_to_name
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> string
  -> Ocdwm_core.Tag.Policy.t
  -> (Yojson.Safe.t option, string) result

(** [toggle_floating ctx seat] toggles [seat]'s focused window between tiled and
    floating. Is [Error _] when the window is fullscreen.

    {b Effects:} mutates WM state; sends River request *)
val toggle_floating
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result

(** [maximize ctx window] ends any seat operation and maximizes [window].

    {b Effects:} mutates WM state; sends River request *)
val maximize : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Window.t -> unit

(** [unmaximize ctx window] restores [window] from its maximized state.

    {b Effects:} mutates WM state; sends River request *)
val unmaximize : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Window.t -> unit

(** [fullscreen ctx output window cb] makes [window] fullscreen on [output], or
    on its own output when [output] is [None], moving it between outputs when
    needed. Calls [cb] with [Exit_fullscreen] for each fullscreen window visible
    on the target output.

    {b Effects:} mutates WM state; sends River request *)
val fullscreen
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Output.t option
  -> Ocdwm_state.Window.t
  -> (Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
      -> Ocdwm_state.Window.t
      -> Ocdwm_state.Window.Request.t
      -> unit)
  -> unit

(** [exit_fullscreen ctx window] restores [window] from its fullscreen state.
    No-op when [window] is not fullscreen.

    {b Effects:} mutates WM state; sends River request *)
val exit_fullscreen
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Window.t
  -> unit

(** [select_layout ctx seat name] sets the layout registered as [name] on the
    first selected tag of [seat]'s output; tiled windows leaving the [floating]
    layout remember their geometry. Is [Error _] when no layout is registered as
    [name] or [seat] has no output.

    {b Effects:} mutates WM state *)
val select_layout
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> string
  -> (Yojson.Safe.t option, string) result

(** [cycle_layout ctx seat dir] sets the current layout's registered neighbor in
    [dir] on the first selected tag of [seat]'s output; tiled windows leaving
    the [floating] layout remember their geometry. Is [Error _] when [seat] has
    no output.

    {b Effects:} mutates WM state *)
val cycle_layout
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [close_focused seat] asks [seat]'s focused window to close.

    {b Effects:} sends River request *)
val close_focused : Ocdwm_state.Seat.t -> (Yojson.Safe.t option, string) result

(** [move_to ~x ~y ctx seat] moves [seat]'s focused window to the extents [x] and
    [y]. Is [Error _] when the window is fullscreen.

    {b Effects:} mutates WM state; sends River request *)
val move_to
  :  x:Ocdwm_core.Extent.t
  -> y:Ocdwm_core.Extent.t
  -> Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result

(** [move_spatial ctx seat dir by] moves [seat]'s focused window in [dir] by
    [by]. Is [Error _] when the window is fullscreen.

    {b Effects:} mutates WM state; sends River request *)
val move_spatial
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Spatial.t
  -> Ocdwm_core.Extent.t
  -> (Yojson.Safe.t option, string) result

(** [resize_to ~width ~height ctx seat] resizes [seat]'s focused window to the
    extents [width] and [height]. Is [Error _] when the window is fullscreen.

    {b Effects:} mutates WM state; sends River request *)
val resize_to
  :  width:Ocdwm_core.Extent.t
  -> height:Ocdwm_core.Extent.t
  -> Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result

(** [resize_spatial ctx seat dir by] resizes [seat]'s focused window in [dir] by
    [by]. Is [Error _] when the window is fullscreen.

    {b Effects:} mutates WM state; sends River request *)
val resize_spatial
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Spatial.t
  -> Ocdwm_core.Extent.t
  -> (Yojson.Safe.t option, string) result
