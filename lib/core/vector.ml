type t =
  { x : int
  ; y : int
  }

let position_of_box (r : int Rect.t) = { x = r.x + (r.w / 2); y = r.y + (r.h / 2) }
let diff a b = { x = b.x - a.x; y = b.y - a.y }

let direction v =
  let open Physical_direction in
  match v with
  | { x; y } when x = 0 && y = 0 -> None
  | { x; y } when abs y > abs x -> Some (if y > 0 then Down else Up)
  | { x; y } -> Some (if x > 0 then Right else Left)
;;

let length_squared v = (v.x * v.x) + (v.y * v.y)

let nearest_in_direction ~from ~dir project xs =
  List.fold_left
    (fun acc x ->
       match project x with
       | None -> acc
       | Some pos ->
         let v = diff from pos in
         (match direction v with
          | Some d when d = dir ->
            let d_sq = length_squared v in
            (match acc with
             | None -> Some (x, d_sq)
             | Some (_, best_sq) when d_sq < best_sq -> Some (x, d_sq)
             | _ -> acc)
          | _ -> acc))
    None
    xs
  |> Option.map fst
;;
