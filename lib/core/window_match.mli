type t =
  { pattern : Pattern.t
  ; invert : bool
  ; scope : Scope.t
  }

(** [to_string m] renders [m] for display: the pattern text, then the invert and
    scope tags in brackets. *)
val to_string : t -> string

(** [compile m] compiles [m] into a matcher. The matcher inverts its result when
    [m.invert] is true. Is [Error msg] when a regex is malformed. *)
val compile : t -> (Pattern.Matcher.t, string) result

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
