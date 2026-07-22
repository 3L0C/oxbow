type t =
  | Tiling
  | Scrolling
  | Floating

(** [to_string t] is [t]'s name in lowercase. *)
val to_string : t -> string

(** [of_string s] is the layout named by [s], trimmed and case-insensitive;
    [None] when unrecognized. *)
val of_string : string -> t option

val t_of_yojson : Ppx_yojson_conv_lib.Yojson.Safe.t -> t
val yojson_of_t : t -> Ppx_yojson_conv_lib.Yojson.Safe.t
