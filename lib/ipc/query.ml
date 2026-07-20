open! Ppx_yojson_conv_lib.Yojson_conv
open! Ocdwm_core

type t =
  | Rules [@name "rules"]
  | Keymaps of { all : bool } [@name "keymaps"]
  | Outputs [@name "outputs"]
  | Focused [@name "focused"]
  | Windows of { query : Window_query.t option } [@name "windows"]
[@@deriving yojson]
