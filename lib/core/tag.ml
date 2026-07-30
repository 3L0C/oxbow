open! Ppx_yojson_conv_lib.Yojson_conv

module Set = struct
  type t = int [@@deriving yojson]

  let max_tag = 32
  let min_tag = 1
  let empty = 0
  let all = (1 lsl max_tag) - 1
  let in_range i = i >= min_tag && i <= max_tag

  let singleton = function
    | i when not @@ in_range i ->
      Printf.sprintf "%d is outside bounds [1..32]" i |> invalid_arg
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
      | i when singleton i |> intersects s -> Some (singleton i)
      | i -> aux (i + 1)
    in
    aux 1
  ;;

  let first_index s =
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
      | i when s lsr i |> is_empty -> Some (singleton i)
      | i -> aux (i + 1)
    in
    aux 1
  ;;

  let last_index s =
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
        singleton i |> f;
        aux (i + 1)
      | i -> aux (i + 1)
    in
    aux 1
  ;;

  let iteri f s =
    let rec aux = function
      | i when not @@ in_range i -> ()
      | i when mem i s ->
        singleton i |> f i;
        aux (i + 1)
      | i -> aux (i + 1)
    in
    aux 1
  ;;

  let to_list s =
    let rec aux acc = function
      | i when not @@ in_range i -> List.rev acc
      | i when mem i s -> aux (singleton i :: acc) (i + 1)
      | i -> aux acc (i + 1)
    in
    aux [] 1
  ;;

  let to_index_list s =
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

  let of_string s =
    let s = String.trim s in
    if s = ""
    then Error "empty tag specification"
    else if
      String.length s >= 2
      && s.[0] = '0'
      &&
      let c = Char.lowercase_ascii s.[1] in
      c = 'x' || c = 'b' || c = 'o'
    then (
      match int_of_string_opt s with
      | Some n -> Ok (of_int n)
      | None -> Error (Printf.sprintf "bad bitmask: %s" s))
    else (
      let parts = String.split_on_char ',' s |> List.map String.trim in
      let parse_range r =
        match String.split_on_char '-' r |> List.map String.trim with
        | [ start; stop ] ->
          (match int_of_string_opt start, int_of_string_opt stop with
           | Some i, Some j ->
             let t_min = min i j in
             let t_max = max i j in
             if in_range t_min && in_range t_max
             then Ok (List.init (t_max - t_min + 1) (fun i -> i + t_min))
             else
               Error
                 (Printf.sprintf
                    "tag range outside [%d..%d], got: %d-%d"
                    min_tag
                    max_tag
                    t_min
                    t_max)
           | _ -> Error (Printf.sprintf "tag malformed: %S" r))
        | _ -> Error (Printf.sprintf "tag range malformed: %s" r)
      in
      let rec collect acc = function
        | [] -> Ok acc
        | x :: xs ->
          if String.contains x '-'
          then (
            match parse_range x with
            | Ok lst -> collect (lst @ acc) xs
            | Error _ as e -> e)
          else (
            match int_of_string_opt x with
            | Some n when in_range n -> collect (n :: acc) xs
            | Some n -> Error (Printf.sprintf "tag %d outside [%d..%d]" n min_tag max_tag)
            | None -> Error (Printf.sprintf "not a tag: %S" x))
      in
      Result.map of_indices (collect [] parts))
  ;;

  let to_string (s : t) = to_list s |> List.map string_of_int |> String.concat ","
  let yojson_of_t (t : t) : Yojson.Safe.t = `Int (to_int t)

  let t_of_yojson (yo_t : Yojson.Safe.t) : t =
    let open Ppx_yojson_conv_lib.Yojson_conv in
    match yo_t with
    | `Int n -> of_int n
    | j -> raise @@ Of_yojson_error (Failure "expected integer", j)
  ;;
end

module Arg = struct
  type t =
    | Concrete of Set.t [@name "concrete"]
    | Occupied [@name "occupied"]
  [@@deriving yojson]
end

module Policy = struct
  type t =
    | Keep [@name "keep"]
    | Take [@name "take"]
  [@@deriving yojson]
end
