(** [begin_move ctx seat window] focuses [window] and begins the pointer move
    operation on [seat].

    {b Effects:} mutates WM state; sends River request *)
val begin_move
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_state.Window.t
  -> unit

(** [begin_resize ctx seat window] focuses [window] and begins the pointer
    resize operation on [seat] and [window].

    {b Effects:} mutates WM state; sends River request *)
val begin_resize
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_state.Window.t
  -> int32
  -> unit

(** [step ctx seat] carries out the next drag operation step in [seat].

    {b Effects:} mutates WM state; sends River request *)
val step : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Seat.t -> unit
