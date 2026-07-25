open! Ocdwm_core

let split ~total ~count =
  if count <= 0
  then []
  else (
    let size = total / count in
    let rem = total mod count in
    List.init count (fun i -> if i < rem then size + 1 else size))
;;

let rec subdivide ~pick (area : int Rect.t) k n =
  if n <= 1
  then [ area ]
  else (
    let win, rest =
      match pick k with
      | `Top ->
        let top = { area with h = max 1 (area.h / 2) } in
        top, { area with y = area.y + top.h; h = area.h - top.h }
      | `Bottom ->
        let bot = { area with h = max 1 (area.h / 2) } in
        { area with y = area.y + bot.h; h = area.h - bot.h }, bot
      | `Left ->
        let left = { area with w = max 1 (area.w / 2) } in
        left, { area with x = area.x + left.w; w = area.w - left.w }
      | `Right ->
        let right = { area with w = max 1 (area.w / 2) } in
        { area with x = area.x + right.w; w = area.w - right.w }, right
    in
    win :: subdivide ~pick rest (k + 1) (n - 1))
;;

let dwindle_pick k = if k mod 2 = 0 then `Top else `Left

let spiral_pick k =
  match k mod 4 with
  | 0 -> `Top
  | 1 -> `Right
  | 2 -> `Bottom
  | _ -> `Left
;;

let diminish_ratio = 0.6

let diminish_heights ~total n =
  let rec go remaining i =
    if i = n - 1
    then [ remaining ]
    else (
      let ideal = Float.of_int remaining *. diminish_ratio |> Int.of_float in
      let reserve = n - 1 - i in
      let h = max 1 (min ideal (remaining - reserve)) in
      h :: go (remaining - h) (i + 1))
  in
  if n <= 0 then [] else go total 0
;;

let column ~x ~w ~y heights =
  List.fold_left_map (fun y h -> y + h, Rect.{ x; y; w; h }) y heights |> snd
;;

let compute ~(params : Params.Tiling.t) ~(usable_area : int Rect.t) ~(count : int) =
  match count with
  | 0 -> []
  | n ->
    let tiled clients_for =
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
      let m_heights = split ~total:mh ~count:m_count in
      let masters = column ~x:usable_area.x ~w:mw ~y:usable_area.y m_heights in
      let c_area =
        Rect.{ x = usable_area.x + mw; y = usable_area.y; w = cw; h = usable_area.h }
      in
      let clients = clients_for ~c_area ~cw ~c_count in
      masters @ clients
    in
    (match params.scheme with
     | Monocle -> List.init n (fun _ -> usable_area)
     | Even ->
       tiled
       @@ fun ~c_area ~cw ~c_count ->
       split ~total:c_area.h ~count:c_count |> column ~x:c_area.x ~w:cw ~y:c_area.y
     | Diminish ->
       tiled
       @@ fun ~c_area ~cw ~c_count ->
       diminish_heights ~total:c_area.h c_count |> column ~x:c_area.x ~w:cw ~y:c_area.y
     | Dwindle ->
       tiled
       @@ fun ~c_area ~cw:_ ~c_count ->
       if c_count = 0 then [] else subdivide ~pick:dwindle_pick c_area 0 c_count
     | Spiral ->
       tiled
       @@ fun ~c_area ~cw:_ ~c_count ->
       if c_count = 0 then [] else subdivide ~pick:spiral_pick c_area 0 c_count)
;;
