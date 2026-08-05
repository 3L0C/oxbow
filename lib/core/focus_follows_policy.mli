type t =
  | Never
  | Always
  | Not_scrolling

(** [all] is the list of all follow policies. *)
val all : t list

(** [to_string policy] is the string representation of [policy]. *)
val to_string : t -> string

(** [cycle policy] is the policy after [policy], in the order of [all]. *)
val cycle : t -> t

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
