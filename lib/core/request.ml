open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  { cmd : Action.t
  ; seat : string option [@yojson.option]
  }
[@@deriving yojson]
