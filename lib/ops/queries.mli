(** [handle wm seat query] is the reply to [query]. *)
val handle
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_ipc.Query.t
  -> (Yojson.Safe.t option, string) result
