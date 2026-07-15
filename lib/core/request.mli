module Body : sig
  type t =
    | Trigger of Action.t
    | Setting of Setting.t
    | Query of Query.t

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

type t =
  { body : Body.t
  ; seat : string option
  }

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
