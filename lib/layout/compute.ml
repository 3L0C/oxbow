open! Ocdwm_core

type t = params:Params.Tiling.t -> usable_area:int Rect.t -> count:int -> int Rect.t list
