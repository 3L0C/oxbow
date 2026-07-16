(** [exec argv] executes [argv] as a separate process.

    {b Effects:} I/O *)
val exec : string array -> (Yojson.Safe.t option, string) result

(** [spawn cmd] spawns [cmd] as [/bin/sh -c cmd].

    {b Effects:} I/O *)
val spawn : string -> (Yojson.Safe.t option, string) result
