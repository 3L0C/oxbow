open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Rules [@name "rules"]
  | Keymaps of { all : bool } [@name "keymaps"]
  | Outputs [@name "outputs"]
  | Focused [@name "focused"]
[@@deriving yojson]
