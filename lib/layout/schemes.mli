(** [split ~total ~count] is an int list of length [count], where each element
    is equal to [total / count]. If [total mod count <> 0] then
    [total mod count] elements are eqaul to [(total / count) + 1]. *)
val split : total:int -> count:int -> int list

(** [compute ~params ~usable_area ~count] is one rectangle per window for the
    scheme in [params]. *)
val compute
  :  params:Params.Tiling.t
  -> usable_area:int Ocdwm_core.Rect.t
  -> count:int
  -> int Ocdwm_core.Rect.t list
