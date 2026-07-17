open! Ppx_yojson_conv_lib.Yojson_conv

module Pattern = struct
  type t =
    | Substring of string [@name "substring"]
    | Regex of string [@name "regex"]
  [@@deriving yojson]
end

module Field = struct
  type t =
    | Any [@name "any"]
    | Title [@name "title"]
    | App_id [@name "app-id"]
  [@@deriving yojson]
end

module Matcher = struct
  type t = title:string option -> app_id:string option -> bool
end

type t =
  { pattern : Pattern.t
  ; field : Field.t
  }
[@@deriving yojson]

let to_string q =
  let field =
    match q.field with
    | Any -> None
    | Title -> Some "title"
    | App_id -> Some "app-id"
  in
  let regex =
    match q.pattern with
    | Substring _ -> None
    | Regex _ -> Some "regex"
  in
  let tags = List.filter_map Fun.id [ field; regex ] in
  let s =
    match q.pattern with
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

let of_string ?(field = Field.Any) s = { pattern = Substring s; field }

let get_regex q =
  match q.pattern with
  | Substring s -> Ok (Str.regexp_string_case_fold s)
  | Regex s ->
    (try Ok (Str.regexp s) with
     | Failure e -> Error e)
;;

let compile q =
  match get_regex q with
  | Error e -> Error e
  | Ok r ->
    let matches_opt = function
      | Some s ->
        (try
           ignore @@ Str.search_forward r s 0;
           true
         with
         | Not_found -> false)
      | None -> false
    in
    Ok
      (fun ~title ~app_id ->
        match q.field with
        | Any -> matches_opt title || matches_opt app_id
        | Title -> matches_opt title
        | App_id -> matches_opt app_id)
;;
