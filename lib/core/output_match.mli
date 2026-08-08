type t =
  { name : string option
  ; label : string option
  ; case : Pattern.Case.t
  ; invert : bool
  }

(** [is_empty m] is [true] when [m] has no match candidates. *)
val is_empty : t -> bool

(** [to_string m] renders [m] for display: the fields, then the case rule in
    parentheses (when it is not the default), then the inversion, if present, in
    brackets. *)
val to_string : t -> string

(** [compile m] compiles [m] into a matcher. An output matches when every field
    of [m] matches; an absent field matches any value. Is [Error msg] when a
    regex is malformed. *)
val compile : t -> (name:string option -> labels:string list -> bool, string) result

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
