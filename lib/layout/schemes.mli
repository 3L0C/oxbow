(** [compute scheme] is [scheme]'s compute function. *)
val compute
  :  Ocdwm_core.Scheme.t
  -> params:Params.Tiling.t
  -> usable_area:int Ocdwm_core.Rect.t
  -> count:int
  -> int Ocdwm_core.Rect.t list
