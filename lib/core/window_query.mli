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

module Matcher : sig
  type t = title:string option -> app_id:string option -> bool
end

type t =
  { pattern : Pattern.t
  ; field : Field.t
  }

(** [to_string q] renders [q] for display: the pattern text followed by its
    non-default qualifiers in parentheses. *)
val to_string : t -> string

(** [of_string ?field s] is the [Substring] query for [s]; [field] defaults to
    [Any]. *)
val of_string : ?field:Field.t -> string -> t

(** [compile q] compiles [q] into a matcher. Is [Error msg] when the regex is
    malformed. *)
val compile : t -> (Matcher.t, string) result

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
