type t =
  | Focused
  | Unfocused
  | Urgent
  | Swallowing
  | Captured

(** [all] is every layout, in cycle order. *)
val all : t list

(** [to_string t] is [t]'s name in lowercase. *)
val to_string : t -> string

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
