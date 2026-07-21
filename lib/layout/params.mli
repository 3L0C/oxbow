type t =
  { mutable mfact : float
  ; mutable nmaster : int
  ; mutable gaps_inner : int
  ; mutable gaps_outer : int
  ; mutable stack : Ocdwm_core.Stack_kind.t
  ; mutable dir : Ocdwm_core.Direction.Spatial.t
  ; mutable scroll_policy : Ocdwm_core.Scroll_policy.t
  }
