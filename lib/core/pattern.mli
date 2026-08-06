module Case : sig
  type t =
    | Sensitive
    | Insensitive

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Matcher : sig
  type t =
    title:string option
    -> app_id:string option
    -> identifier:string option
    -> labels:string list
    -> bool
end

type t =
  { title : string option
  ; app_id : string option
  ; identifier : string option
  ; label : string option
  ; case : Case.t
  }

(** [equal a b] is true when [a] and [b] hold equal criteria and an equal case
    rule. *)
val equal : t -> t -> bool

(** [is_empty p] is true when [p] holds no criterion. Such a pattern matches
    every window. *)
val is_empty : t -> bool

(** [re_compile ~case s] compiles [s] as a PCRE regex with the case flag of
    [case]. *)
val re_compile : case:Case.t -> string -> (Re.re, string) result

(** [matches ~case ~pattern str] is [true] when [pattern] is absent, or when its
    regex matches [str]. Is [false] when the regex is malformed, logging an
    error. *)
val matches : case:Case.t -> pattern:string option -> string -> bool

(** [compile p] compiles [p] into a matcher. A window matches when every field
    of [p] matches; an absent field matches any value. Is [Error msg] when a
    regex is malformed. *)
val compile : t -> (Matcher.t, string) result

(** [to_string p] renders [p] for display: the fields, then the case rule in
    parentheses when it is not the default. *)
val to_string : t -> string

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
