open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | By_direction of Direction.t [@name "direction"]
  | By_name of string [@name "name"]
[@@deriving yojson]

let to_string = function
  | By_direction d -> Direction.to_string d
  | By_name n -> n
;;

let of_string s =
  match Direction.of_string s with
  | Some d -> By_direction d
  | None -> By_name s
;;
