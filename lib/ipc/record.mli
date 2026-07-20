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
    { id : int
    ; identifier : string option
    ; title : string option
    ; app_id : string option
    ; output : string option
    ; tags : int list
    ; focused : bool
    ; urgent : bool
    ; hidden : bool
    ; presentation : string
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
    ; tags : int list option
    }

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

type t =
  | Tags
  | Window
  | Layout
  | Mode
  | Focus

val all : t list
val equal : t -> t -> bool
val of_string : string -> (t, string) result
val to_string : t -> string
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> [> `String of string ]
