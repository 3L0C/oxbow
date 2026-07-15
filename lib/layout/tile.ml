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
    let w =
      usable_area.w
      (* Two gaps, one left and one right *)
      - (params.gaps_outer * 2)
      (* Inner gaps only present when both master and client stack >= 1 *)
      - if m_count > 0 && c_count > 0 then params.gaps_inner else 0
    in
    (* ensure w is >= 0 in the case of very large gaps. Is >= 1 when m_count and
       c_count are >= 1. *)
    let w = min m_count c_count |> max w in
    let mw =
      match m_count, c_count with
      | 0, _ -> 0
      | _, 0 -> w
      | _, _ -> Float.of_int w *. params.mfact |> Int.of_float
    in
    let mh =
      usable_area.h
      (* Two gaps, one top and one bottom *)
      - (params.gaps_outer * 2)
      (* there are m - 1 gaps between windows in any stack (i.e., edges to nodes) *)
      - if m_count > 0 then params.gaps_inner * (m_count - 1) else 0
    in
    (* ensure [mh] is >= 0 *)
    let mh = max mh m_count in
    let cw =
      match m_count, c_count with
      | _, 0 -> 0
      | 0, _ -> w
      | _, _ -> w - mw
    in
    let ch =
      usable_area.h
      (* Two gaps, one top and one bottom *)
      - (params.gaps_outer * 2)
      (* there are m - 1 gaps between windows in any stack (i.e., edges to nodes) *)
      - if c_count > 0 then params.gaps_inner * (c_count - 1) else 0
    in
    (* ensure [ch] is >= 0 *)
    let ch = max ch c_count in
    let m_heights = split ~total:mh ~count:m_count in
    let c_heights = split ~total:ch ~count:c_count in
    let cx = params.gaps_outer + mw + if m_count > 0 then params.gaps_inner else 0 in
    let column ~x ~w ~y ~gap heights =
      List.fold_left_map (fun y h -> y + h + gap, Rect.{ x; y; w; h }) y heights |> snd
    in
    let masters =
      column
        ~x:(usable_area.x + params.gaps_outer)
        ~w:mw
        ~y:(usable_area.y + params.gaps_outer)
        ~gap:params.gaps_inner
        m_heights
    in
    let clients =
      column
        ~x:(usable_area.x + cx)
        ~w:cw
        ~y:(usable_area.y + params.gaps_outer)
        ~gap:params.gaps_inner
        c_heights
    in
    masters @ clients
;;
