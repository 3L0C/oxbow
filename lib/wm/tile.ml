open! Ocdwm_core

let name = "tile"
let symbol = Symbol.S_static "[]="

let split ~total ~count =
  if count <= 0
  then []
  else (
    let size = total / count in
    let rem = total mod count in
    List.init count (fun i -> if i < rem then size + 1 else size))
;;

let compute ~(data : Layout_params.t) ~(area : int Rect.t) ~(count : int) =
  match count with
  | 0 -> []
  | n ->
    let c_count = Int.max 0 (n - data.nmaster) in
    let m_count = Int.max 0 (n - c_count) in
    let w =
      area.w
      - (data.gaps_outer * 2) (* Two gaps, one left and one right *)
      - if c_count > 0 then data.gaps_inner else 0
      (* No inner gaps if no clients *)
    in
    (* ensure w is positive in the case of very large gaps *)
    let w = min m_count c_count |> max w in
    let mw =
      match m_count, c_count with
      | 0, _ -> 0
      | _, 0 -> w
      | _, _ -> Float.of_int w *. data.mfact |> Int.of_float
    in
    let mh =
      area.h
      - (data.gaps_outer * 2) (* Two gaps, one left and one right *)
      -
      (* there are m - 1 gaps between windows in any stack (i.e., edges to nodes) *)
      if m_count > 0 then data.gaps_inner * (m_count - 1) else 0
    in
    (* ensure [mh] is positive *)
    let mh = max mh m_count in
    let cw =
      match m_count, c_count with
      | _, 0 -> 0
      | 0, _ -> w
      | _, _ -> w - mw
    in
    let ch =
      area.h
      - (data.gaps_outer * 2) (* Two gaps, one left and one right *)
      -
      (* there are m - 1 gaps between windows in any stack (i.e., edges to nodes) *)
      if c_count > 0 then data.gaps_inner * (c_count - 1) else 0
    in
    (* ensure [ch] is positive *)
    let ch = max ch c_count in
    let m_heights = split ~total:mh ~count:m_count in
    let c_heights = split ~total:ch ~count:c_count in
    let cx = data.gaps_outer + mw + if m_count > 0 then data.gaps_inner else 0 in
    let column ~x ~w ~y ~gap heights =
      List.fold_left_map (fun y h -> y + h + gap, Rect.{ x; y; w; h }) y heights |> snd
    in
    let masters =
      column
        ~x:(area.x + data.gaps_outer)
        ~w:mw
        ~y:(area.y + data.gaps_outer)
        ~gap:data.gaps_inner
        m_heights
    in
    let clients =
      column
        ~x:(area.x + cx)
        ~w:cw
        ~y:(area.y + data.gaps_outer)
        ~gap:data.gaps_inner
        c_heights
    in
    masters @ clients
;;
