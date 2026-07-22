(** [compute ~params ~usable_area ~count] is a list of window dimensions of
    length [count]. Each dimension is equal to [usable_area]. *)
val compute
  :  params:Params.Tiling.t
  -> usable_area:int Ocdwm_core.Rect.t
  -> count:int
  -> int Ocdwm_core.Rect.t list
