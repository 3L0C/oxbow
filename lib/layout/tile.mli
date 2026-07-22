val name : string
val symbol : Symbol.t

(** [split ~total ~count] is an int list of length [count], where each element
    is equal to [total / count]. If [total mod count <> 0] then [total mod count]
    elements are eqaul to [(total / count) + 1]. *)
val split : total:int -> count:int -> int list

(** [compute ~params ~usable_area ~count] is a list of window dimensions of
    length [count]. The arrangement is the same as dwm's tile layout with a
    master and client stack; split by [params]' nmaster and mfact values,
    respectively. *)
val compute
  :  params:Params.Tiling.t
  -> usable_area:int Ocdwm_core.Rect.t
  -> count:int
  -> int Ocdwm_core.Rect.t list
