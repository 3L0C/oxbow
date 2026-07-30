(** [filter wm seat scope] is the window list of [wm], narrowed to [scope].
    [Focused] uses the output of [seat]. An unknown output name is an error. *)
val filter
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Scope.t
  -> (Ocdwm_state.Window.t list, string) result
