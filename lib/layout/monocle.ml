open! Ocdwm_core

let name = "monocle"
let symbol = Symbol.Dynamic (fun ctx -> Printf.sprintf "[%d]" ctx.focused_index)

let compute ~params:_ ~(usable_area : int Rect.t) ~(count : int) =
  match count with
  | 0 -> []
  | n -> List.init n (fun i -> usable_area)
;;
