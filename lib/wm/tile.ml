open! Ocdwm_core

let name = "tile"
let symbol = Symbol.S_static "[]="

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
    let mw =
      match m_count, c_count with
      | 0, _ -> 0
      | _, 0 -> w
      | _, _ -> Float.of_int w |> ( *. ) data.mfact |> Int.of_float
    in
    let mh =
      area.h
      - (data.gaps_outer * 2) (* Two gaps, one left and one right *)
      -
      (* there are m - 1 gaps between windows in any stack (i.e., edges to nodes) *)
      if m_count > 0 then data.gaps_inner * (m_count - 1) else 0
    in
    let mwh = if m_count > 0 then mh / m_count else 0 in
    let cw =
      match c_count, m_count with
      | 0, _ -> 0
      | _, 0 -> w
      | _, _ -> Float.of_int w |> ( *. ) (1.0 -. data.mfact) |> Int.of_float
    in
    let ch =
      area.h
      - (data.gaps_outer * 2) (* Two gaps, one left and one right *)
      -
      (* there are m - 1 gaps between windows in any stack (i.e., edges to nodes) *)
      if c_count > 0 then data.gaps_inner * (c_count - 1) else 0
    in
    let cwh = if c_count > 0 then ch / c_count else 0 in
    let cx = data.gaps_outer + mw + if m_count > 0 then data.gaps_inner else 0 in
    let masters =
      List.init m_count (fun i ->
        Rect.
          { x = area.x + data.gaps_outer
          ; y = area.y + data.gaps_outer + ((mwh + data.gaps_inner) * i)
          ; w = mw
          ; h = mwh
          })
    in
    let clients =
      List.init c_count (fun i ->
        Rect.
          { x = area.x + cx
          ; y = area.y + data.gaps_outer + ((cwh + data.gaps_inner) * i)
          ; w = cw
          ; h = cwh
          })
    in
    masters @ clients
;;
