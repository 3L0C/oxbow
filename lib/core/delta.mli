type 'a t =
  | Abs of 'a
  | Rel of 'a

val t_of_yojson : (Yojson.Safe.t -> 'a) -> Yojson.Safe.t -> 'a t
val yojson_of_t : ('a -> Yojson.Safe.t) -> 'a t -> Yojson.Safe.t
