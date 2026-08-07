module Window : sig
  type t =
    | Focused
    | Matching of
        { wmatch : Window_match.t
        ; all : bool
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
