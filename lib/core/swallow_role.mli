type t =
  | Auto
  | Terminal
  | Disabled

(** [all] is the list containing all the swallow roles. *)
val all : t list

(** [to_string role] is the string representation of [role]. *)
val to_string : t -> string

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
