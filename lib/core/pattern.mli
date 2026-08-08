module Case : sig
  type t =
    | Sensitive
    | Insensitive

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

(** [re_compile ~case s] compiles [s] as a PCRE regex with the case flag of
    [case]. *)
val re_compile : case:Case.t -> string -> (Re.re, string) result

(** [matches ~case ~pattern str] is [true] when [pattern] is absent, or when its
    regex matches [str]. Is [false] when the regex is malformed, logging an
    error. *)
val matches : case:Case.t -> pattern:string option -> string -> bool

(** [compile_specs ~case specs] compiles [specs] into a matching function. *)
val compile_specs
  :  case:Case.t
  -> (string option * ('a -> string list)) list
  -> ('a -> bool, string) result
