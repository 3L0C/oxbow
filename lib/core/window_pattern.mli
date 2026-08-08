type t =
  { title : string option
  ; app_id : string option
  ; identifier : string option
  ; label : string option
  ; case : Pattern.Case.t
  }

(** [equal a b] is true when [a] and [b] hold equal criteria and an equal case
    rule. *)
val equal : t -> t -> bool

(** [is_empty p] is true when [p] holds no criterion. Such a pattern matches
    every window. *)
val is_empty : t -> bool

(** [to_string p] renders [p] for display: the fields, then the case rule in
    parentheses when it is not the default. *)
val to_string : t -> string

(** [compile p] compiles [p] into a matcher. A window matches when every field
    of [p] matches; an absent field matches any value. Is [Error msg] when a
    regex is malformed. *)
val compile
  :  t
  -> ( title:string option
       -> app_id:string option
       -> identifier:string option
       -> labels:string list
       -> bool
       , string )
       result

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
