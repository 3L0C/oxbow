(** [handle wm window request] carries out [request] on [window].

    {b Effects:} mutates WM state *)
val handle
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Window.t
  -> Oxbow_state.Window.Request.t
  -> unit

(** [toggle_maximize wm seat target] toggles maximization on the window
    [target]. Is [Error msg] when the window is fullscreen.

    {b Effects:} mutates WM state *)
val toggle_maximize
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.One.t
  -> (Yojson.Safe.t option, string) result

(** [toggle_fake_fullscreen wm seat target] toggles fake fullscreen on the
    [target] windows. Is [Error msg] when any [target] window is actually
    fullscreen.

    {b Effects:} mutates WM state *)
val toggle_fake_fullscreen
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.Any.t
  -> (Yojson.Safe.t option, string) result

(** [toggle_fullscreen wm seat target] toggles fullscreen on the [target]
    window. Is [Error msg] when the [target] window has no output.

    {b Effects:} mutates WM state *)
val toggle_fullscreen
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.One.t
  -> (Yojson.Safe.t option, string) result

(** [move_interactive wm seat] begins a pointer move of [seat]'s hovered window.
    Is [Error msg] when called during an active operation, there is no hovered
    window, or hovered window is fullscreen.

    {b Effects:} mutates WM state *)
val move_interactive
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> (Yojson.Safe.t option, string) result

(** [resize_interactive wm seat] begins a pointer resize of [seat]'s hovered
    window from its bottom-right. Is [Error msg] when called during an active
    operation, there is no hovered window, or hovered window is fullscreen.

    {b Effects:} mutates WM state *)
val resize_interactive
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> (Yojson.Safe.t option, string) result
