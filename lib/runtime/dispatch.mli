(** [handle ctx seat request] carries out [request] on behalf of [seat].

    {b Effects:} mutates WM state; sends River request; I/O

    @raise [Exceptions.Finished]*)
val handle
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_state.Pending_request.t
  -> unit
