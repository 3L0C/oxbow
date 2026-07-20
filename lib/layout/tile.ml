open! Ocdwm_core

let name = "tile"
let symbol = Symbol.Static "[]="

let split ~total ~count =
  if count <= 0
  then []
  else (
    let size = total / count in
    let rem = total mod count in
    List.init count (fun i -> if i < rem then size + 1 else size))
;;

let compute ~(params : Params.t) ~(usable_area : int Rect.t) ~(count : int) =
  match count with
  | 0 -> []
  | n ->
    let c_count = Int.max 0 (n - params.nmaster) in
    let m_count = Int.max 0 (n - c_count) in
    let w = usable_area.w in
    let mw =
      match m_count, c_count with
      | 0, _ -> 0
      | _, 0 -> w
      | _, _ -> Float.of_int w *. params.mfact |> Int.of_float
    in
    let mh = usable_area.h in
    let cw =
      match m_count, c_count with
      | _, 0 -> 0
      | 0, _ -> w
      | _, _ -> w - mw
    in
    let ch = usable_area.h in
    let m_heights = split ~total:mh ~count:m_count in
    let c_heights = split ~total:ch ~count:c_count in
    let column ~x ~w ~y heights =
      List.fold_left_map (fun y h -> y + h, Rect.{ x; y; w; h }) y heights |> snd
    in
    let masters = column ~x:usable_area.x ~w:mw ~y:usable_area.y m_heights in
    let clients = column ~x:(usable_area.x + mw) ~w:cw ~y:usable_area.y c_heights in
    masters @ clients
;;
