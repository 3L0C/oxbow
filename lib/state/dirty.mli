(** [install c] defines [c] as the closure to notify River when a manage
    sequence is needed via [manage_dirty].

    {b Effects:} mutates WM state *)
val install : (unit -> unit) -> unit

(** [mark_seat seat] marks [seat] dirty.

    {b Effects:} mutates WM state; sends River request *)
val mark_seat : Types.Seat.t -> unit

(** [mark_output output] marks [output] dirty.

    {b Effects:} mutates WM state; sends River request *)
val mark_output : Types.Output.t -> unit

(** [mark_wm wm] marks [wm] dirty.

    {b Effects:} mutates WM state; sends River request *)
val mark_wm : Types.Wm.t -> unit

(** [mark_all wm] marks [wm] and all [output]s and [seat]s dirty.

    {b Effects:} mutates WM state; sends River request *)
val mark_all : Types.Wm.t -> unit

(** [with_deferred wm f] runs [f ()] with manage_dirty requests suppressed; on
    exit (normal or exceptional) sends a single request iff any dirty flag
    survived: [wm] or any output/seat lifecycle still [Dirty _]. *)
val with_deferred : Types.Wm.t -> (unit -> 'a) -> 'a
