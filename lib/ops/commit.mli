(** [capabilities ctx window] sets the fullscreen and maximize capabilities of
    [window].

    {b Effects:} sends River request *)
val capabilities
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Window.t
  -> unit

(** [dimensions ctx window] sets [window]'s dimensions to its recorded geometry,
    or clears the dimensions if a float seed is pending.

    {b Effects:} sends River request *)
val dimensions : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Window.t -> unit

(** [decoration ctx window] syncs [window]'s tiled edges and server/client-side
    decoration choice with its presentation and decoration hint.

    {b Effects:} sends River request *)
val decoration : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Window.t -> unit

(** [presentation ctx window] sends the necessary requests when [window]'s
    presentation is fullscreen, maximized, or fake fullscreen.

    {b Effects:} sends River request *)
val presentation
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Window.t
  -> unit

(** [presentation_mode ctx output] syncs [output]'s presentation mode with that
    of its focused window, or [Vsync] if no window is focused.

    {b Effects:} sends River request *)
val presentation_mode
  :  Ocdwm_state.Ctx.render Ocdwm_state.Ctx.t
  -> Ocdwm_state.Output.t
  -> unit

(** [resizing ctx window] sends resize start/end according to [window]'s state.

    {b Effects:} sends River request *)
val resizing : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Window.t -> unit

(** [focus ctx seat] adjust the focus state of [seat].

    {b Effects:} sends River request *)
val focus : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Seat.t -> unit

(** [node ctx window] syncs the node state of [window].

    {b Effects:} sends River request *)
val node : Ocdwm_state.Ctx.render Ocdwm_state.Ctx.t -> Ocdwm_state.Window.t -> unit
