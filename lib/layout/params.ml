open! Oxbow_core

module Tiling = struct
  type t =
    { mutable scheme : Scheme.t
    ; mutable mfact : float
    ; mutable nmaster : int
    ; mutable dir : Direction.Spatial.t
    }
end

module Scrolling = struct
  type t =
    { mutable align : Align.t
    ; mutable default_width : Width_fac.t
    ; mutable offset : int
    ; mutable dir : Direction.Spatial.t
    }
end

module Gaps = struct
  type t =
    { mutable inner : int
    ; mutable outer : int
    }
end
