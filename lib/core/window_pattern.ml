open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  { title : string option [@yojson.option]
  ; app_id : string option [@yojson.option]
  ; identifier : string option [@yojson.option]
  ; label : string option [@yojson.option]
  ; case : Pattern.Case.t
  }
[@@deriving yojson]

let equal (a : t) (b : t) = a = b

let is_empty = function
  | { title = None; app_id = None; identifier = None; label = None; case = _ } -> true
  | _ -> false
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
      ; field_value "label" p.label
      ]
  in
  match p.case with
  | Sensitive -> String.concat " " parts
  | Insensitive -> String.concat " " parts |> Printf.sprintf "%s (insensitive)"
;;

let compile m =
  Pattern.compile_specs
    ~case:m.case
    [ (m.title, fun (t, _, _, _) -> Option.to_list t)
    ; (m.app_id, fun (_, a, _, _) -> Option.to_list a)
    ; (m.identifier, fun (_, _, i, _) -> Option.to_list i)
    ; (m.label, fun (_, _, _, ls) -> ls)
    ]
  |> Result.map (fun m ~title ~app_id ~identifier ~labels ->
    m (title, app_id, identifier, labels))
;;
