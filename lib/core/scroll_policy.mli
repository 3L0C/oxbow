type t =
  | Visible
  | Left
  | Centered

(** [all] is a list of all scrolling policies. *)
val all : t list

(** [to_string policy] is the string representation of [policy]. *)
val to_string : t -> string

(** [of_string s] is the scroll policy represented by [s] or [Error msg] if [s]
    does not represent any scroll policy. *)
val of_string : string -> (t, string) result

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
