(** [handle wm window request] carries out [request] on [window].

    {b Effects:} mutates WM state *)
val handle
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Window.t
  -> Ocdwm_state.Window.Request.t
  -> unit

(** [toggle_maximize wm seat] toggles maximization on [seat]'s focused window.
    Is [Error msg] when the window is fullscreen.

    {b Effects:} mutates WM state *)
val toggle_maximize
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result

(** [toggle_fake_fullscreen wm seat] toggles fake fullscreen on [seat]'s
    focused window. Is [Error msg] when the window is actually fullscreen.

    {b Effects:} mutates WM state *)
val toggle_fake_fullscreen
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result

(** [toggle_fullscreen wm seat] toggles fullscreen on [seat]'s focused window.

    {b Effects:} mutates WM state *)
val toggle_fullscreen
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result

(** [move_interactive wm seat] begins a pointer move of [seat]'s hovered
    window. Is [Error msg] when called during an active operation, there is no
    hovered window, or hovered window is fullscreen.

    {b Effects:} mutates WM state *)
val move_interactive
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result

(** [resize_interactive wm seat] begins a pointer resize of [seat]'s hovered
    window from its bottom-right. Is [Error msg] when called during an active
    operation, there is no hovered window, or hovered window is fullscreen.

    {b Effects:} mutates WM state *)
val resize_interactive
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result
