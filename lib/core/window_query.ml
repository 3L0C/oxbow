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
    | Identifier [@name "identifier"]
  [@@deriving yojson]
end

module Case = struct
  type t =
    | Sensitive [@name "sensitive"]
    | Insensitive [@name "insensitive"]
  [@@deriving yojson]
end

module Matcher = struct
  type t = title:string option -> app_id:string option -> identifier:string option -> bool
end

type t =
  { pattern : Pattern.t
  ; field : Field.t
  ; case : Case.t
  }
[@@deriving yojson]

let to_string q =
  let field =
    match q.field with
    | Any -> None
    | Title -> Some "title"
    | App_id -> Some "app-id"
    | Identifier -> Some "identifier"
  in
  let regex =
    match q.pattern with
    | Substring _ -> None
    | Regex _ -> Some "regex"
  in
  let case =
    match q.case with
    | Sensitive -> Some "sensitive"
    | Insensitive -> Some "insensitive"
  in
  let tags = List.filter_map Fun.id [ field; regex; case ] in
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

let of_string ?(field = Field.Any) ?(case = Case.Sensitive) s =
  { pattern = Substring s; field; case }
;;

let get_regex q =
  match q.pattern with
  | Substring s -> Ok (Re.compile (Re.no_case (Re.str s)))
  | Regex s ->
    let flags =
      match q.case with
      | Sensitive -> []
      | Insensitive -> [ `CASELESS ]
    in
    (try Ok (Re.compile (Re.Pcre.re ~flags s)) with
     | Re.Perl.Parse_error | Re.Perl.Not_supported ->
       Error (Printf.sprintf "invalid regex: %s" s))
;;

let compile q =
  match get_regex q with
  | Error e -> Error e
  | Ok r ->
    let matches_opt = function
      | Some s -> Re.execp r s
      | None -> false
    in
    Ok
      (fun ~title ~app_id ~identifier ->
        match q.field with
        | Any -> matches_opt title || matches_opt app_id
        | Title -> matches_opt title
        | App_id -> matches_opt app_id
        | Identifier -> matches_opt identifier)
;;
