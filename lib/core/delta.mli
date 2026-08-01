type 'a t =
  | Abs of 'a
  | Rel of 'a

val t_of_yojson : (Yojson.Safe.t -> 'a) -> Yojson.Safe.t -> 'a t
val yojson_of_t : ('a -> Yojson.Safe.t) -> 'a t -> Yojson.Safe.t

(** [resolve ~add ~current d] is the value of [d]: [Abs a] is [a], and [Rel r]
    is [add current r]. *)
val resolve : add:('a -> 'a -> 'a) -> current:'a -> 'a t -> 'a
