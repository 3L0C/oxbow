(** [install send] sets the callback that requests a manage sequence from river. *)
val install : (unit -> unit) -> unit

(** [manage ()] requests a manage sequence. Repeat calls coalesce until the next
    tick starts.

    {b Effects:} sends River request *)
val manage : unit -> unit

(** [with_tick f] runs one manage tick [f]. It clears the pending flag first.
    If [f] requests again, it sends once after [f].

    {b Effects:} sends River request *)
val with_tick : (unit -> 'a) -> 'a
