type t =
  | Rules
  | Keymaps of { all : bool }
  | Outputs

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
