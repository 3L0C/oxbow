exception Unavailable

(** [unavailable ()] is used to signal River is unavailable, i.e., another wm is
    already attached.

    @raise [Unavailable] *)
val unavailable : unit -> 'a
