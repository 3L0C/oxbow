module Select : sig
  type t =
    | Best
    | Cycle

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Window : sig
  module One : sig
    type t =
      | Focused
      | Matching of
          { wmatch : Window_match.t
          ; select : Select.t
          }

    val t_of_yojson : Yojson.Safe.t -> t
    val yojson_of_t : t -> Yojson.Safe.t
  end

  module Any : sig
    type t =
      | One of One.t
      | All of { wmatch : Window_match.t }

    val t_of_yojson : Yojson.Safe.t -> t
    val yojson_of_t : t -> Yojson.Safe.t
  end
end

module Output : sig
  module One : sig
    type t =
      | Focused
      | Matching of
          { omatch : Output_match.t
          ; select : Select.t
          }

    val t_of_yojson : Yojson.Safe.t -> t
    val yojson_of_t : t -> Yojson.Safe.t
  end

  module Any : sig
    type t =
      | One of One.t
      | All of { omatch : Output_match.t }

    val t_of_yojson : Yojson.Safe.t -> t
    val yojson_of_t : t -> Yojson.Safe.t
  end
end
