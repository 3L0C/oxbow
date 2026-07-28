(** [arrange wm output] tiles all non-floating windows on [output] according to
    [output]'s currently viewed tags. Is a no-op if [output] is displaying a
    fullscreen window.

    {b Effects:} mutates WM state *)
val arrange : Ocdwm_state.Wm.t -> Ocdwm_state.Output.t -> unit

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
