val name : string
val symbol : Symbol.t

(** [compute ~params ~usable_area ~count] is a list of window dimensions of
    length [count]. The arrangement is the same as dwm's tile layout with a
    master and client stack; split by [params]' nmaster and mfact values,
    respectively. *)
val compute
  :  params:Params.t
  -> usable_area:int Ocdwm_core.Rect.t
  -> count:int
  -> int Ocdwm_core.Rect.t list
