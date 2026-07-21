let move_to_top x xs = x :: List.filter (fun y -> y != x) xs

let rec wrapped_search p l lst =
  let rec aux (wrapped : bool) = function
    | x :: xs when p x -> Some x
    | [ x ] when not wrapped -> l x |> aux true
    | x :: xs -> aux wrapped xs
    | [] -> None
  in
  aux false lst
;;

let next_or_first e = function
  | [] -> None
  | first :: _ as lst ->
    let rec aux = function
      | x :: y :: xs when x == e -> Some y
      | [ x ] when x == e -> Some first
      | _ :: rest -> aux rest
      | [] -> None
    in
    aux lst
;;

let prev_or_last e lst = List.rev lst |> next_or_first e

let shift_right p l =
  let rec aux acc = function
    | [ x ] when p x -> x :: List.rev acc
    | x :: y :: xs when p x -> (List.rev @@ (x :: y :: acc)) @ xs
    | x :: xs -> aux (x :: acc) xs
    | [] -> List.rev acc
  in
  aux [] l
;;

let shift_left p l = List.rev l |> shift_right p |> List.rev

let hop_right sel vis l =
  let rec aux p before = function
    | x :: xs when p x -> Some (List.rev before, x, xs)
    | x :: xs -> aux p (x :: before) xs
    | [] -> None
  in
  match aux sel [] l with
  | None -> l
  | Some (b, x, a) ->
    (match aux vis [] a with
     | Some (b', y, a') -> b @ b' @ [ y; x ] @ a'
     | None ->
       (match aux vis [] b with
        | Some (b', y, a') -> b' @ [ x; y ] @ a' @ a
        | None -> l))
;;

let hop_left sel vis l = List.rev l |> hop_right sel vis |> List.rev

let rearrange vis order l =
  List.fold_left_map
    (fun ol slot ->
       if vis slot
       then (
         match ol with
         | [] -> ol, slot
         | x :: xs -> xs, x)
       else ol, slot)
    order
    l
  |> snd
;;
