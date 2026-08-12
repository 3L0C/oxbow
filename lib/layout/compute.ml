open! Oxbow_core

type t =
  params:Params.Tiling.t
  -> usable_area:int Rect.canonical
  -> count:int
  -> int Rect.canonical list
