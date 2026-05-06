type t = int

let max_tag = 32
let min_tag = 1
let empty = 0
let all = (1 lsl max_tag) - 1
let in_range i = i >= min_tag && i <= max_tag

let singleton = function
  | i when not @@ in_range i ->
    Printf.sprintf "Tag_set: %d is outside bounds [1..32]" i |> invalid_arg
  | i -> 1 lsl (i - 1)
;;

let of_indices = List.fold_left (fun acc i -> singleton i |> ( lor ) acc) 0
let is_empty s = s = empty

let mem i s =
  match i with
  | _ when not @@ in_range i -> false
  | _ -> singleton i |> ( land ) s |> ( <> ) empty
;;

let equal s s' = s = s'
let intersects a b = a land b <> empty
let subset a b = a land b = a
let union a b = a lor b
let inter a b = a land b
let diff a b = a land lnot b
let symmetric_diff a b = a lxor b

let first s =
  let rec aux = function
    | i when not @@ in_range i -> None
    | i when singleton i |> intersects s -> Some i
    | i -> aux (i + 1)
  in
  aux 1
;;

let last s =
  let rec aux = function
    | _ when is_empty s -> None
    | i when s lsr i |> is_empty -> Some i
    | i -> aux (i + 1)
  in
  aux 1
;;

let cardinality s =
  let rec aux acc = function
    | i when not @@ in_range i -> acc
    | i when mem i s -> aux (acc + 1) (i + 1)
    | i -> aux acc (i + 1)
  in
  aux 0 1
;;

let fold f s init =
  let rec aux acc = function
    | i when not @@ in_range i -> acc
    | i when mem i s -> aux (f i acc) (i + 1)
    | i -> aux acc (i + 1)
  in
  aux init 1
;;

let iter f s =
  let rec aux = function
    | i when not @@ in_range i -> ()
    | i when mem i s ->
      f i;
      aux (i + 1)
    | i -> aux (i + 1)
  in
  aux 1
;;

let to_list s =
  let rec aux acc = function
    | i when not @@ in_range i -> List.rev acc
    | i when mem i s -> aux (i :: acc) (i + 1)
    | i -> aux acc (i + 1)
  in
  aux [] 1
;;

let next s =
  match first s with
  | None -> empty
  | Some i when not @@ in_range (i + 1) -> singleton min_tag
  | Some i -> singleton (i + 1)
;;

let prev s =
  match first s with
  | None -> empty
  | Some i when not @@ in_range (i - 1) -> singleton max_tag
  | Some i -> singleton (i - 1)
;;

let next_occupied ~selected ~occupied =
  match is_empty selected, is_empty occupied with
  | true, true -> empty
  | false, true -> selected
  | true, false ->
    (match first occupied with
     | None -> empty
     | Some i -> singleton i)
  | false, false ->
    let selected_first = Option.get @@ first selected in
    let occupied_first = Option.get @@ first occupied in
    let rec aux = function
      | i when not @@ in_range i -> singleton occupied_first
      | i when mem i occupied -> singleton i
      | i -> aux (i + 1)
    in
    aux (selected_first + 1)
;;

let prev_occupied ~selected ~occupied =
  match is_empty selected, is_empty occupied with
  | true, true -> empty
  | false, true -> selected
  | true, false ->
    (match first occupied with
     | None -> empty
     | Some i -> singleton i)
  | false, false ->
    let selected_first = Option.get @@ first selected in
    let occupied_last = Option.get @@ last occupied in
    let rec aux = function
      | i when not @@ in_range i -> singleton occupied_last
      | i when mem i occupied -> singleton i
      | i -> aux (i - 1)
    in
    aux (selected_first - 1)
;;

let to_int s = s
let of_int n = n land all
