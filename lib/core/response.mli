type t =
  { ok : bool
  ; err : string option
  ; data : Yojson.Safe.t option
  }

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
