(** [spawn cmd] runs [cmd] as [/bin/sh -c cmd].

    {b Effects:} I/O *)
val spawn : string -> unit
