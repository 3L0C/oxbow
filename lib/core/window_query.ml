open! Ppx_yojson_conv_lib.Yojson_conv

type pattern =
  | Substring of string [@name "substring"]
  | Regex of string [@name "regex"]
[@@deriving yojson]

type field =
  | Any [@name "any"]
  | Title [@name "title"]
  | App_id [@name "app-id"]
[@@deriving yojson]

type t =
  { query : pattern
  ; fields : field
  ; cycle : bool
  }
[@@deriving yojson]

let to_string q =
  let regex =
    match q.query with
    | Substring _ -> None
    | Regex _ -> Some "regex"
  in
  let fields =
    match q.fields with
    | Any -> None
    | Title -> Some "title"
    | App_id -> Some "app-id"
  in
  let cycle = if q.cycle then Some "cycle" else None in
  let tags = List.filter_map Fun.id [ fields; cycle; regex ] in
  let s =
    match q.query with
    | Substring s -> s
    | Regex s -> s
  in
  let render s =
    match tags with
    | [] -> s
    | _ -> Printf.sprintf "%s (%s)" s (String.concat ", " tags)
  in
  render s
;;

let of_string ?(fields = Any) ?(cycle = false) s = { query = Substring s; fields; cycle }

let get_regex q =
  match q.query with
  | Substring s -> Ok (Str.regexp_string_case_fold s)
  | Regex s ->
    (try Ok (Str.regexp s) with
     | Failure e -> Error e)
;;
