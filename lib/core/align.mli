type t =
  | Visible
  | Left
  | Centered

(** [all] is a list of all alignments. *)
val all : t list

(** [to_string t] is the string representation of [t]. *)
val to_string : t -> string

(** [of_string s] is the alignment represented by [s] or [Error msg] if [s] does
    not represent any alignment. *)
val of_string : string -> (t, string) result

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
