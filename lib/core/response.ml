open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  { ok : bool
  ; err : string option [@yojson.option]
  }
[@@deriving yojson]
