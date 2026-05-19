open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | By_direction of Direction.t [@name "direction"]
  | By_query of Window_query.t [@name "query"]
[@@deriving yojson]

let to_string = function
  | By_direction d -> Direction.to_string d
  | By_query q -> Window_query.to_string q
;;

let of_string s =
  match Direction.of_string s with
  | Some d -> By_direction d
  | None -> By_query (Window_query.of_string s)
;;
