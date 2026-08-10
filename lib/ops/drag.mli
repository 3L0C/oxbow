(** [begin_move ~from_tiled wm seat window] focuses [window] and begins the
    pointer move operation on [seat]. [from_tiled] records the window's tiled
    state at the start of the drag.

    {b Effects:} mutates WM state *)
val begin_move
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_state.Window.t
  -> from_tiled:bool
  -> unit

(** [begin_resize wm seat window] focuses [window] and begins the pointer
    resize operation on [seat] and [window].

    {b Effects:} mutates WM state *)
val begin_resize
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_state.Window.t
  -> int32
  -> unit

(** [step wm seat] carries out the next drag operation step in [seat].

    {b Effects:} mutates WM state *)
val step : Oxbow_state.Wm.t -> Oxbow_state.Seat.t -> unit
