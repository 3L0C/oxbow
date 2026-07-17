open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Rules [@name "rules"]
  | Keymaps of { all : bool } [@name "keymaps"]
[@@deriving yojson]
