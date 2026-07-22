module Tiling : sig
  type t =
    { mutable scheme : Ocdwm_core.Scheme.t
    ; mutable mfact : float
    ; mutable nmaster : int
    ; mutable stack : Ocdwm_core.Stack_kind.t
    ; mutable dir : Ocdwm_core.Direction.Spatial.t
    }
end

module Scrolling : sig
  type t =
    { mutable policy : Ocdwm_core.Scroll_policy.t
    ; mutable default_width : Ocdwm_core.Width_fac.t
    }
end

module Gaps : sig
  type t =
    { mutable inner : int
    ; mutable outer : int
    }
end
