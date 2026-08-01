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

let re_compile ~(case : Case.t) s =
  let flags =
    match case with
    | Sensitive -> []
    | Insensitive -> [ `CASELESS ]
  in
  try Ok Re.(compile (Pcre.re ~flags s)) with
  | Re.Pcre.(Parse_error | Not_supported) -> Error (Printf.sprintf "invalid regex: %s" s)
;;

let matches ~case ~pattern str =
  match pattern with
  | None -> true
  | Some s ->
    (match re_compile ~case s with
     | Error msg ->
       Logs.err (fun m -> m "%s" msg);
       false
     | Ok re -> Re.execp re str)
;;

let compile (p : t) =
  let comp = function
    | None -> Ok None
    | Some s -> Result.map Option.some (re_compile ~case:p.case s)
  in
  match comp p.title, comp p.app_id, comp p.identifier with
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
