let name = "monocle"
let symbol = Symbol.S_dynamic (fun ctx -> Printf.sprintf "[%d]" ctx.focused_index)

let compute ~(data : Layout_params.t) ~(area : int Rect.t) ~(count : int) =
  match count with
  | 0 -> []
  | n ->
    List.init n (fun i ->
      Rect.
        { x = area.x + data.gaps_outer
        ; y = area.y + data.gaps_outer
        ; w = area.w - (data.gaps_outer * 2)
        ; h = area.h - (data.gaps_outer * 2)
        })
;;
