type t =
  | Bind of
      { keybind : string
      ; command : Command.t
      ; mode : string option
      }
  | Unbind of
      { keybind : string
      ; mode : string option
      }

val t_of_yojson : Ppx_yojson_conv_lib.Yojson.Safe.t -> t
val yojson_of_t : t -> Ppx_yojson_conv_lib.Yojson.Safe.t
