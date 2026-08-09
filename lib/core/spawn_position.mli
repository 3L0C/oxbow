type t =
  | Master
  | Prev
  | Next
  | End

(** [all] is the list of all spawn position variants. *)
val all : t list

(** [to_string position] is the string representation of [t]. *)
val to_string : t -> string

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
