module Logical : sig
  type t =
    | Next
    | Prev

  (** [to_string d] is the string representation of [d]:
      - [Next] -> "next"
      - [Prev] -> "prev" *)
  val to_string : t -> string

  (** [of_string s] is the direction named by [s], trimmed and case-insensitive;
      [None] when unrecognized. *)
  val of_string : string -> t option

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Spatial : sig
  type t =
    | Up
    | Down
    | Left
    | Right

  (** [to_string d] is the string representation of [d]:
      - [Up] -> "up"
      - [Down] -> "down"
      - [Left] -> "left"
      - [Right] -> "right" *)
  val to_string : t -> string

  (** [of_string s] is the direction named by [s], trimmed and case-insensitive;
      [None] when unrecognized. *)
  val of_string : string -> t option

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

type t =
  | Logical of Logical.t
  | Spatial of Spatial.t

(** [to_string d] is the wrapped direction's string. *)
val to_string : t -> string

(** [of_string s] tries [Logical.of_string] first, then [Spatial.of_string];
    [None] when neither recognizes [s]. *)
val of_string : string -> t option

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
