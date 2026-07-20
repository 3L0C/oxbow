type t =
  | Rules
  | Keymaps of { all : bool }
  | Outputs
  | Focused
  | Windows of { query : Ocdwm_core.Window_query.t option }

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
