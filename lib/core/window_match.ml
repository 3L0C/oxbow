open! Ppx_yojson_conv_lib.Yojson_conv

module Scope = struct
  type t =
    | All [@name "all"]
    | Focused [@name "focused"]
    | Output of string [@name "output"]
  [@@deriving yojson]
end

type t =
  { pattern : Pattern.t
  ; invert : bool
  ; scope : Scope.t
  }
[@@deriving yojson]

let to_string m =
  let pattern = Pattern.to_string m.pattern in
  let invert = if m.invert then Some "invert" else None in
  let scope =
    match m.scope with
    | All -> None
    | Focused -> Some "focused"
    | Output name -> Some (Printf.sprintf "output %s" name)
  in
  let tags = List.filter_map Fun.id [ invert; scope ] in
  match tags with
  | [] -> pattern
  | _ -> String.concat ", " tags |> Printf.sprintf "%s [%s]" pattern
;;

let compile m =
  match Pattern.compile m.pattern with
  | Error e -> Error e
  | Ok matcher ->
    Ok
      (fun ~title ~app_id ~identifier ->
        let hit = matcher ~title ~app_id ~identifier in
        if m.invert then not hit else hit)
;;
