(** [handle ctx seat request] carries out [request] on behalf of [seat].

    {b Effects:} mutates WM state; I/O *)
val handle
  :  Ctx.manage Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_state.Pending_request.t
  -> unit
