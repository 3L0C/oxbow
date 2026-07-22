(** [handle wm seat query] is the reply to [query]. *)
val handle
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_ipc.Query.t
  -> (Yojson.Safe.t option, string) result
