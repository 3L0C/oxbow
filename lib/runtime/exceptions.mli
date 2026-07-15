exception Finished
exception Unavailable

(** [finished ()] is used to signal ocdwm is finished executing. Called when River
    signals it will not send any more events.

    @raise [Finished] *)
val finished : unit -> 'a

(** [unavailable ()] is used to signal River is unavailable, i.e., another wm is
    already attached.

    @raise [Unavailable] *)
val unavailable : unit -> 'a
