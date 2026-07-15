module Pattern : sig
  type t =
    { app_id : string option
    ; title : string option
    }

  (** [equal a b] is true when [a] and [b] have equal [app_id] and [title]. *)
  val equal : t -> t -> bool

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Action : sig
  type t =
    | Set_tags of Tag.Arg.t
    | Send_to_output of
        { name : string
        ; policy : Tag.Policy.t
        }
    | Float
    | Tile
    | Fullscreen
    | Windowed

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

type t =
  { pattern : Pattern.t
  ; action : Action.t
  }

(** [eqaul a b] is [true] when [a] and [b] have equal patterns and equal
    actions. *)
val equal : t -> t -> bool

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
