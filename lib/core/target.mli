module Select : sig
  type t =
    | Best
    | All
    | Cycle

  (** [all] is the list of all selection strategies. *)
  val all : t list

  (** [to_string select] is the string representation of [select]. *)
  val to_string : t -> string

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Window : sig
  type t =
    | Focused
    | Matching of
        { wmatch : Window_match.t
        ; select : Select.t
        }

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Output : sig
  type t =
    | Focused
    | Matching of string

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

type t =
  | Window of Window.t
  | Output of Output.t

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
