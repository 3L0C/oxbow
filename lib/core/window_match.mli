module Matcher : sig
  type t =
    title:string option
    -> app_id:string option
    -> identifier:string option
    -> labels:string list
    -> bool
end

type t =
  { pattern : Window_pattern.t
  ; invert : bool
  ; scope : Scope.t
  }

(** [to_string m] renders [m] for display: the pattern text, then the invert and
    scope tags in brackets. *)
val to_string : t -> string

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
