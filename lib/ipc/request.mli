module Body : sig
  type t =
    | Command of Command.t
    | Keymap of Keymap.t
    | Query of Query.t
    | Subscribe of Event.Subscribe.t

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

type t =
  { body : Body.t
  ; seat : string option
  }

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
