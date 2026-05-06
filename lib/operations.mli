(** [seat_op ctx seat] carries out the operation queued in [seat].

    {b Effects:} mutates WM state; sends River request *)
val seat_op : Ctx.manage Ctx.t -> Seat.t -> unit
