module Kind : sig
  type t =
    | Tags
    | Window
    | Layout
    | Mode
    | Focus

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
  val all : t list
  val equal : t -> t -> bool
  val of_string : string -> (t, string) result
  val to_string : t -> string
end

module Tags : sig
  type t =
    { output : string
    ; viewed : int list
    ; occupied : int list
    ; urgent : int list
    ; focused : int list
    }

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Window : sig
  type t =
    { output : string
    ; title : string option
    ; app_id : string option
    }

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Layout : sig
  type t =
    { output : string
    ; layout : string
    ; symbol : string
    }

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Mode : sig
  type t =
    { seat : string
    ; mode : string
    }

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Focus : sig
  type t =
    { seat : string
    ; output : string option
    ; title : string option
    ; app_id : string option
    }

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Subscribe : sig
  type t =
    { kinds : Kind.t list
    ; output : string option
    }

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

type t =
  | Tags of Tags.t
  | Window of Window.t
  | Layout of Layout.t
  | Mode of Mode.t
  | Focus of Focus.t

val kind : t -> Kind.t
val source : t -> string
val to_line : t -> string
