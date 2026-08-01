module Class : sig
  type t =
    | Touchpad
    | Mouse

  (** [to_string c] is the lowercase name of [c]. *)
  val to_string : t -> string
end

module Role : sig
  type t =
    | Keyboard
    | Mouse
    | Touchpad
    | Touch
    | Tablet

  (** [to_string c] is the lowercase name of [c]. *)
  val to_string : t -> string

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end
