open! Ocdwm_core

let name = "monocle"
let symbol = Symbol.Dynamic (fun ctx -> Printf.sprintf "[%d]" ctx.focused_index)

let compute ~(params : Params.t) ~(usable_area : int Rect.t) ~(count : int) =
  match count with
  | 0 -> []
  | n ->
    List.init n (fun i ->
      Rect.
        { x = usable_area.x + params.gaps_outer
        ; y = usable_area.y + params.gaps_outer
        ; w = usable_area.w - (params.gaps_outer * 2)
        ; h = usable_area.h - (params.gaps_outer * 2)
        })
;;
