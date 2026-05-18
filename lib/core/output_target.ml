open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Out_direction of Direction.t [@name "direction"]
  | Out_name of string [@name "name"]
[@@deriving yojson]
