open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Bind of
      { keybind : string
      ; action : Action.t
      } [@name "bind"]
[@@deriving yojson]
