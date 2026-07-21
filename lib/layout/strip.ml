open! Ocdwm_core

module Item = struct
  type t =
    { consumes : bool
    ; width_fac : float
    }
end

let split ~total ~count =
  if count <= 0
  then []
  else (
    let size = total / count in
    let rem = total mod count in
    List.init count (fun i -> if i < rem then size + 1 else size))
;;

let layout ~(usable : int Rect.t) ~offset (items : ('a * Item.t) list) =
  let rec group (items : ('a * Item.t) list) =
    match items with
    | [] -> []
    | ((_, it) as x) :: rest ->
      (match group rest, it.consumes with
       | col :: cols, true -> (x :: col) :: cols
       | cols, _ -> [ x ] :: cols)
  in
  let column_width (col : ('a * Item.t) list) =
    let fac = (List.hd col |> snd).width_fac in
    float_of_int usable.w *. fac |> int_of_float |> max 1
  in
  let place ~cursor col =
    let width = column_width col in
    let heights = split ~total:usable.h ~count:(List.length col) in
    let _, placed =
      List.combine col heights
      |> List.fold_left_map
           (fun y ((member, _), h) ->
              y + h, (member, Rect.{ x = cursor; y; w = width; h }))
           usable.y
    in
    placed
  in
  let _, per_column =
    List.fold_left_map
      (fun cursor col ->
         let width = column_width col in
         cursor + width, place ~cursor col)
      (usable.x - offset)
      (group items)
  in
  List.concat per_column
;;

let scroll ~(policy : Scroll_policy.t) ~viewport_w ~total_w ~offset ~col:(x, w) =
  let ideal =
    match policy with
    | Left -> x
    | Centered -> x - ((viewport_w - w) / 2)
    | Visible ->
      if w > viewport_w
      then x
      else if x < offset
      then x
      else if x + w > offset + viewport_w
      then x + w - viewport_w
      else offset
  in
  min ideal (total_w - viewport_w) |> max 0
;;
