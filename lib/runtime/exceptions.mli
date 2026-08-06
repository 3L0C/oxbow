exception Unavailable

(** [unavailable ()] is used to signal River is unavailable, i.e., another wm is
    already attached.

    @raise [Unavailable] *)
val unavailable : unit -> 'a

(** [guard name f] runs [f]. If [f] raises, [guard] logs the exception with a
    backtrace under [name], then returns. It re-raises [Unavailable] and
    [Eio.Cancel.Cancelled]. *)
val guard : string -> (unit -> unit) -> unit
