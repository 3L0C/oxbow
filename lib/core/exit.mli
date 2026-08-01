(** [ok] indicates successful termination *)
val ok : int

(** [unavailable] indicates service unavailable *)
val unavailable : int

(** [software] indicates an internal software error *)
val software : int

(** [exits] is the exit information for [Cmdliner] covering every code. *)
val exits : Cmdliner.Cmd.Exit.info list
