(** [manage ctx] sends the state changes from a manage sequence to River.

    {b Effects:} sends River request *)
val manage : Ctx.manage Ctx.t -> unit

(** [render ctx] sends the state changes from a render sequence to River.

    {b Effects:} sends River request *)
val render : Ctx.render Ctx.t -> unit
