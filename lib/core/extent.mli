type t =
  | Px of int
  | Pct of float

(** [resolve ~ref e] is [e] in pixels: [Px n] is [n]; [Pct f] is [f] percent of
    [ref], rounded to the nearest integer. *)
val resolve : ref:int -> t -> int

(** [to_string e] is a string [of_string] parses back to [e]. *)
val to_string : t -> string

(** [of_string s] parses ["50"] as [Px 50] and ["12.5%"] as [Pct 12.5];
    [Error msg] when malformed. *)
val of_string : string -> (t, string) result

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
