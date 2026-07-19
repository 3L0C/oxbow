(** [opt_equal a b] is [true] when [a] and [b] are both [None] or hold
    physically equal ([==]) values. *)
val opt_equal : 'a option -> 'a option -> bool

(** [opt_holds v o] is [true] when [o] holds [v] itself ([==]). *)
val opt_holds : 'a -> 'a option -> bool
