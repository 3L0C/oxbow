(** [snapshots wm] is the current event snapshot for every (kind * source) in
    [wm], in publish order. *)
val snapshots
  :  Ocdwm_state.Wm.t
  -> ((Ocdwm_ipc.Record.t * string) * Ocdwm_ipc.Event.t) list

(** [seed wm sub] fills [sub]'s pending buffer with the last-published snapshots
    matching its filters and wakes its drain fiber.

    {b Effects:} mutates WM state *)
val seed : Ocdwm_state.Wm.t -> Ocdwm_state.Wm.Ipc.Subscriber.t -> unit

(** [publish wm] diffs current snapshots against the last-published set, updates
    matching subscribers with the changes, and records the new set.

    {b Effects:} mutates WM state *)
val publish : Ocdwm_state.Wm.t -> unit
