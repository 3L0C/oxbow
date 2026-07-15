type t =
  | Even
  | Diminish
  | Dwindle

(** [to_string k] is [k]'s name in lowercase. *)
val to_string : t -> string

(** [of_string s] is the kind named by [s], trimmed and case-insensitive; [None]
    when unrecognized. *)
val of_string : string -> t option

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
