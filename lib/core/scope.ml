open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | All [@name "all"]
  | Focused [@name "focused"]
  | Output of string [@name "output"]
[@@deriving yojson]
