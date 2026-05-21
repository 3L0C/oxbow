open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Tag_keep [@name "tag_keep"]
  | Tag_take [@name "tag_take"]
[@@deriving yojson]
