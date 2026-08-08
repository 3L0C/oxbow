open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  { name : string option [@yojson.option]
  ; label : string option [@yojson.option]
  ; case : Pattern.Case.t
  ; invert : bool
  }
[@@deriving yojson]

let is_empty = function
  | { name = None; label = None; case = _; invert = _ } -> true
  | _ -> false
;;

let to_string m =
  let field_value name value =
    match value with
    | None -> None
    | Some s -> Some (Printf.sprintf "%s=%s" name s)
  in
  let invert = if m.invert then Some "[invert]" else None in
  let parts =
    List.filter_map
      Fun.id
      [ field_value "name" m.name; field_value "label" m.label; invert ]
  in
  let body = String.concat " " parts in
  match m.case with
  | Sensitive -> body
  | Insensitive -> Printf.sprintf "%s (insensitive)" body
;;

let compile m =
  Pattern.compile_specs
    ~case:m.case
    [ (m.name, fun (n, _) -> Option.to_list n); (m.label, fun (_, ls) -> ls) ]
  |> Result.map (fun m ~name ~labels -> m (name, labels))
;;
