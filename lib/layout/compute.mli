type t =
  params:Params.Tiling.t
  -> usable_area:int Oxbow_core.Rect.canonical
  -> count:int
  -> int Oxbow_core.Rect.canonical list
