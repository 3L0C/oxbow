module Pattern : sig
  type t =
    | Substring of string
    | Regex of string

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Field : sig
  type t =
    | Any
    | Title
    | App_id

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

type t =
  { pattern : Pattern.t
  ; field : Field.t
  ; cycle : bool
  }

(** [to_string q] renders [q] for display: the pattern text followed by its
    non-default qualifiers in parentheses. *)
val to_string : t -> string

(** [of_string ?field ?cycle s] is the [Substring] query for [s]; [field]
    defaults to [Any], [cycle] to [false]. *)
val of_string : ?field:Field.t -> ?cycle:bool -> string -> t

(** [get_regex q] compiles [q]'s pattern: a case-insensitive literal for
    [Substring], [Str] syntax for [Regex]. [Error msg] when the regex is
    malformed. *)
val get_regex : t -> (Str.regexp, string) result

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
