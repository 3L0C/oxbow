(** [handle ctx window request] carries out [request] on [window].

    {b Effects:} mutates WM state; sends River request *)
val handle
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Window.t
  -> Ocdwm_state.Window.Request.t
  -> unit

(** [toggle_maximize ctx seat] toggles maximization on [seat]'s focused window.
    Is [Error msg] when the window is fullscreen.

    {b Effects:} mutates WM state; sends River request *)
val toggle_maximize
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result

(** [toggle_fake_fullscreen ctx seat] toggles fake fullscreen on [seat]'s
    focused window. Is [Error msg] when the window is actually fullscreen.

    {b Effects:} mutates WM state; sends River request *)
val toggle_fake_fullscreen
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result

(** [toggle_fullscreen ctx seat] toggles fullscreen on [seat]'s focused window.

    {b Effects:} mutates WM state; sends River request *)
val toggle_fullscreen
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result

(** [move_interactive ctx seat] begins a pointer move of [seat]'s hovered
    window. Is [Error msg] when called during an active operation, there is no
    hovered window, or hovered window is fullscreen.

    {b Effects:} mutates WM state; sends River request *)
val move_interactive
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result

(** [resize_interactive ctx seat] begins a pointer resize of [seat]'s hovered
    window from its bottom-right. Is [Error msg] when called during an active
    operation, there is no hovered window, or hovered window is fullscreen.

    {b Effects:} mutates WM state; sends River request *)
val resize_interactive
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> (Yojson.Safe.t option, string) result
