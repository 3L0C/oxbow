(** [handle_window_request ctx window request] carries out [request] on [window].

    {b Effects:} mutates WM state; sends River request *)
val window_request : Ctx.manage Ctx.t -> Types.Window.t -> Types.Window_request.t -> unit

(** [focus_request ctx seat] handles the focus request on [seat].

    {b Effects:} mutates WM state; sends River request *)
val focus_request : Ctx.manage Ctx.t -> Types.Seat.t -> unit

(** [interaction ctx seat] handles the interaction request on [seat].

    {b Effects:} mutates WM state; sends River request *)
val interaction : Ctx.manage Ctx.t -> Types.Seat.t -> unit

(** [action ctx seat action] carries out [action] on behalf of [seat].

    {b Effects:} mutates WM state; sends River request; I/O

    @raise [Exceptions.Finished]*)
val action : Ctx.manage Ctx.t -> Types.Seat.t -> Action.t -> unit
