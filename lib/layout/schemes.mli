(** [compute ~params ~usable_area ~count] is one rectangle per window for the
    scheme in [params]. *)
val compute
  :  params:Params.Tiling.t
  -> usable_area:int Ocdwm_core.Rect.t
  -> count:int
  -> int Ocdwm_core.Rect.t list
