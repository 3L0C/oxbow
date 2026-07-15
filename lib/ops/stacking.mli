(** [remove_window ~window output] removes [window] from [output] if [output]
    manages [window].

    {b Effects:} mutates WM state *)
val remove_window : window:Ocdwm_state.Window.t -> Ocdwm_state.Output.t -> unit

(** [push windows output] pushes [windows] to the top of the tile and focus stack
    of [output].

    {b Effects:} mutates WM state *)
val push : Ocdwm_state.Window.t list -> Ocdwm_state.Output.t -> unit

(** [focus_window ctx seat window] focuses [window].

    {b Effects:} mutates WM state; sends River request *)
val focus_window
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_state.Window.t
  -> unit

(** [shift seat dir] shifts the focused window one slot in [dir] through the
    tile stack, wrapping at the head and tail. No-op when there is no focused
    window.

    {b Effects:} mutates WM state *)
val shift
  :  Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result
