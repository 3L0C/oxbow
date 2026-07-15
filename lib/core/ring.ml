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

let shift_left p l = List.rev @@ shift_right p @@ List.rev l
