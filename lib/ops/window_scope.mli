(** [filter wm seat scope] is the window list of [wm], narrowed to [scope].
    [Focused] uses the output of [seat]. An unknown output name is an error. *)
val filter
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Scope.t
  -> (Oxbow_state.Window.t list, string) result

(** [holds matches window] is [matches] applied to [window]. *)
val holds
  :  (title:string option
      -> app_id:string option
      -> identifier:string option
      -> labels:string list
      -> bool)
  -> Oxbow_state.Window.t
  -> bool

(** [matching wm seat m] is the compiled pattern matcher [m] and a filtered list
    of matching windows. Is [Error msg] if [m] fails to compile, or [m] is
    scoped to an unknown output. *)
val matching
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Window_match.t
  -> ((Oxbow_state.Window.t -> bool) * Oxbow_state.Window.t list, string) result
