open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  { body : Request_body.t
  ; seat : string option [@yojson.option]
  }
[@@deriving yojson]
