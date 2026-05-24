open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Bind of
      { keyspec : string
      ; action : Action.t
      } [@name "bind"]
[@@deriving yojson]
