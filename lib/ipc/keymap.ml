open! Ppx_yojson_conv_lib.Yojson_conv

type t =
  | Bind of
      { keybind : string
      ; command : Command.t
      } [@name "bind"]
  | Unbind of string [@name "unbind"]
[@@deriving yojson]
