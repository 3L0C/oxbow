open! Ocdwm_core

let pre (dir : Direction.Spatial.t) (area : int Rect.t) =
  match dir with
  | Left | Right -> area
  | Up | Down -> { x = 0; y = 0; w = area.h; h = area.w }
;;

let post (dir : Direction.Spatial.t) ~(area : int Rect.t) (rect : int Rect.t) =
  let mirror_x (r : int Rect.t) = { r with x = area.x + area.w - (r.x - area.x) - r.w } in
  let mirror_y (r : int Rect.t) = { r with y = area.y + area.h - (r.y - area.y) - r.h } in
  let swap (r : int Rect.t) = { r with x = area.x + r.y; y = area.y + r.x } in
  match dir with
  | Left -> rect
  | Right -> mirror_x rect
  | Up -> swap rect
  | Down -> swap rect |> mirror_y
;;
