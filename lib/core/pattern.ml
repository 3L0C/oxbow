open! Ppx_yojson_conv_lib.Yojson_conv

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
  { title : string option [@yojson.option]
  ; app_id : string option [@yojson.option]
  ; identifier : string option [@yojson.option]
  ; case : Case.t
  }
[@@deriving yojson]

let equal (a : t) (b : t) = a = b
let is_empty (p : t) = p.title = None && p.app_id = None && p.identifier = None

let compile (p : t) =
  let flags =
    match p.case with
    | Case.Sensitive -> []
    | Insensitive -> [ `CASELESS ]
  in
  let re_compile = function
    | None -> Ok None
    | Some s ->
      (try Ok (Some (Re.compile (Re.Pcre.re ~flags s))) with
       | Re.Pcre.Parse_error | Re.Pcre.Not_supported ->
         Error (Printf.sprintf "invalid regex: %s" s))
  in
  match re_compile p.title, re_compile p.app_id, re_compile p.identifier with
  | Error e, _, _ | _, Error e, _ | _, _, Error e -> Error e
  | Ok title, Ok app_id, Ok identifier ->
    let hit re value =
      match re, value with
      | None, _ -> true
      | Some _, None -> false
      | Some re, Some v -> Re.execp re v
    in
    Ok
      (fun ~title:w_title ~app_id:w_app_id ~identifier:w_identifier ->
        hit title w_title && hit app_id w_app_id && hit identifier w_identifier)
;;

let to_string p =
  let field_value name value =
    match value with
    | None -> None
    | Some s -> Some (Printf.sprintf "%s=%s" name s)
  in
  let parts =
    List.filter_map
      Fun.id
      [ field_value "title" p.title
      ; field_value "app-id" p.app_id
      ; field_value "identifier" p.identifier
      ]
  in
  let body = String.concat " " parts in
  match p.case with
  | Case.Sensitive -> body
  | Case.Insensitive -> Printf.sprintf "%s (insensitive)" body
;;
