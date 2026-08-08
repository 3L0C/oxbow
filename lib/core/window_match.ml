open! Ppx_yojson_conv_lib.Yojson_conv

module Matcher = struct
  type t =
    title:string option
    -> app_id:string option
    -> identifier:string option
    -> labels:string list
    -> bool
end

type t =
  { pattern : Window_pattern.t
  ; invert : bool
  ; scope : Scope.t
  }
[@@deriving yojson]

let to_string m =
  let pattern = Window_pattern.to_string m.pattern in
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
