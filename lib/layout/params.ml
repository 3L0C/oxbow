open! Ocdwm_core

type t =
  { mutable mfact : float
  ; mutable nmaster : int
  ; mutable gaps_inner : int
  ; mutable gaps_outer : int
  ; mutable stack : Stack_kind.t
  ; mutable dir : Direction.Spatial.t
  }
