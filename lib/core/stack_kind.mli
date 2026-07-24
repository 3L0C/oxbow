type t =
  | Even
  | Diminish
  | Dwindle
  | Spiral

(** [all] is every stack, in cycle order. *)
val all : t list

(** [to_string k] is [k]'s name in lowercase. *)
val to_string : t -> string

(** [of_string s] is the kind named by [s], trimmed and case-insensitive; [None]
    when unrecognized. *)
val of_string : string -> t option

(** [cycle t dir] is the stack that follows [t] in [dir]. Wraps at the ends of
    [all]. *)
val cycle : t -> Direction.Logical.t -> t

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
