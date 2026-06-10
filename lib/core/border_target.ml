open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Focused [@name "focused"]
  | Unfocused [@name "unfocused"]
  | Urgent [@name "urgent"]
[@@deriving yojson]
