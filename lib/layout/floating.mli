val name : string
val symbol : Symbol.t

(** [compute ~params ~usable_area ~count] is the empty list for any input. *)
val compute : params:Params.t -> usable_area:int Ocdwm_core.Rect.t -> count:int -> 'a list
