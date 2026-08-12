(** [compute ~params ~usable_area ~count] is one rectangle per window for the
    scheme in [params]. *)
val compute
  :  params:Params.Tiling.t
  -> usable_area:int Oxbow_core.Rect.canonical
  -> count:int
  -> int Oxbow_core.Rect.canonical list
