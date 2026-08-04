module Tiling : sig
  type t =
    { mutable scheme : Oxbow_core.Scheme.t
    ; mutable mfact : float
    ; mutable nmaster : int
    ; mutable dir : Oxbow_core.Direction.Spatial.t
    }
end

module Scrolling : sig
  type t =
    { mutable policy : Oxbow_core.Scroll_policy.t
    ; mutable default_width : Oxbow_core.Width_fac.t
    ; mutable offset : int
    }
end

module Gaps : sig
  type t =
    { mutable inner : int
    ; mutable outer : int
    }
end
