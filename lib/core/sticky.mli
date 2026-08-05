module Toggle : sig
  type t =
    | Occupied
    | All

  (** [all] is the list of all sticky toggles. *)
  val all : t list

  (** [to_string toggle] is the string representation of [toggle]. *)
  val to_string : t -> string

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

type t =
  | Off
  | Occupied
  | All

(** [all] is the list of all sticky scopes. *)
val all : t list

(** [to_string scope] is the string representation of [scope]. *)
val to_string : t -> string

(** [of_toggle toggle] is [toggle] mapped to the coresponding scope. *)
val of_toggle : Toggle.t -> t

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
