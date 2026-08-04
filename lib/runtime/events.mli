(** [seed wm sub] fills [sub]'s pending buffer with the last-published snapshots
    matching its filters and wakes its drain fiber.

    {b Effects:} mutates WM state *)
val seed : Oxbow_state.Wm.t -> Oxbow_state.Wm.Ipc.Subscriber.t -> unit

(** [publish wm] diffs current snapshots against the last-published set, updates
    matching subscribers with the changes, and records the new set.

    {b Effects:} mutates WM state *)
val publish : Oxbow_state.Wm.t -> unit
