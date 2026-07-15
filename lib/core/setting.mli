type t =
  | Bind of
      { keybind : string
      ; action : Action.t
      }
  | Unbind of string

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
