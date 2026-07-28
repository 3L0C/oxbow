(** [begin_move wm seat window] focuses [window] and begins the pointer move
    operation on [seat].

    {b Effects:} mutates WM state *)
val begin_move : Ocdwm_state.Wm.t -> Ocdwm_state.Seat.t -> Ocdwm_state.Window.t -> unit

(** [begin_resize wm seat window] focuses [window] and begins the pointer
    resize operation on [seat] and [window].

    {b Effects:} mutates WM state *)
val begin_resize
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_state.Window.t
  -> int32
  -> unit

(** [step wm seat] carries out the next drag operation step in [seat].

    {b Effects:} mutates WM state *)
val step : Ocdwm_state.Wm.t -> Ocdwm_state.Seat.t -> unit
