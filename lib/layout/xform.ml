open! Oxbow_core

let pre (dir : Direction.Spatial.t) (area : int Rect.t) =
  let cross ({ x; y; w; h } : int Rect.t) : int Rect.canonical = { x; y; w; h } in
  match dir with
  | Left | Right -> cross area
  | Up | Down -> { x = 0; y = 0; w = area.h; h = area.w }
;;

let post (dir : Direction.Spatial.t) ~(area : int Rect.t) (rect : int Rect.canonical) =
  let cross ({ x; y; w; h } : int Rect.canonical) : int Rect.t = { x; y; w; h } in
  let mirror_x (r : int Rect.t) = { r with x = area.x + area.w - (r.x - area.x) - r.w } in
  let mirror_y (r : int Rect.t) = { r with y = area.y + area.h - (r.y - area.y) - r.h } in
  let swap (r : int Rect.canonical) =
    Rect.{ x = area.x + r.y; y = area.y + r.x; w = r.h; h = r.w }
  in
  match dir with
  | Left -> cross rect
  | Right -> cross rect |> mirror_x
  | Up -> swap rect
  | Down -> swap rect |> mirror_y
;;
