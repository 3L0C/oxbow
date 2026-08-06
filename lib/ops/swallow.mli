(** [parent_pid] maps a PID to its parent PID. The default reads
    [/proc/<pid>/stat]. Tests replace it. Is [None] when the PID has no parent
    or the read fails. *)
val parent_pid : (int -> int option) ref

(** [try_swallow wm window] finds an eligible terminal ancestor of [window] and
    swallows it. No-op when [window] or every candidate fails an eligibility
    test.

    {b Effects:} mutates WM state *)
val try_swallow : Oxbow_state.Wm.t -> Oxbow_state.Window.t -> unit

(** [unswallow window] restores the host hidden by [window]. No-op when [window]
    swallows nothing.

    {b Effects:} mutates WM state *)
val unswallow : Oxbow_state.Window.t -> unit

(** [on_close window] clears the swallow relation of a closing [window]. A
    closing child restores its host first.

    {b Effects:} mutates WM state *)
val on_close : Oxbow_state.Window.t -> unit

(** [toggle wm seat] swallows under, or restores from, the focused window on
    [seat]. Is [Error msg] when [seat] has no focused window.

    {b Effects:} mutates WM state *)
val toggle
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> (Yojson.Safe.t option, string) result
