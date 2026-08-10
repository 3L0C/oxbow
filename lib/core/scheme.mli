type t =
  | Even
  | Diminish
  | Dwindle
  | Spiral
  | Deck
  | Monocle

(** [all] is every scheme, in cycle order. *)
val all : t list

(** [to_string t] is [t]'s name in lowercase. *)
val to_string : t -> string

(** [of_string s] is the scheme named by [s], trimmed and case-insensitive;
    [None] when unrecognized. *)
val of_string : string -> t option

(** [cycle t dir] is the scheme that follows [t] in [dir]. Wraps at the ends of
    [all]. *)
val cycle : t -> Direction.Logical.t -> t

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
