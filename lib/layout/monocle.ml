open! Ocdwm_core

let compute ~params:_ ~(usable_area : int Rect.t) ~(count : int) =
  match count with
  | 0 -> []
  | n -> List.init n (fun i -> usable_area)
;;
