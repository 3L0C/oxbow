type t =
  | Bind of
      { keybind : string
      ; command : Command.t
      }
  | Unbind of string

val t_of_yojson : Ppx_yojson_conv_lib.Yojson.Safe.t -> t
val yojson_of_t : t -> Ppx_yojson_conv_lib.Yojson.Safe.t
