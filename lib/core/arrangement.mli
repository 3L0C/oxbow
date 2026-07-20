type t =
  | Tiling
  | Scrolling
  | Overview of [ `Tiling | `Scrolling ]

(** [to_string t] is [t]'s name in lowercase. *)
val to_string : t -> string

(** [of_string s] is the arrangement named by [s], trimmed and case-insensitive;
    [None] when unrecognized. *)
val of_string : string -> t option

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
