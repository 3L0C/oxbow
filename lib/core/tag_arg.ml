open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Tags_concrete of Tag_set.t [@name "concrete"]
  | Tags_occupied [@name "occupied"]
[@@deriving yojson]
