module Reply : sig
  module Layouts : sig
    type t = { available : string list }

    val t_of_yojson : Yojson.Safe.t -> t
    val yojson_of_t : t -> Yojson.Safe.t
  end

  module Schemes : sig
    type t = { available : string list }

    val t_of_yojson : Yojson.Safe.t -> t
    val yojson_of_t : t -> Yojson.Safe.t
  end

  module Seats : sig
    type t =
      { name : string
      ; mode : string
      ; output : string option
      }

    val t_of_yojson : Yojson.Safe.t -> t
    val yojson_of_t : t -> Yojson.Safe.t
  end
end

type t =
  | Rules
  | Keymaps of { all : bool }
  | Outputs
  | Focused
  | Windows of { filter : Ocdwm_core.Window_match.t }
  | Tags of { output : string option }
  | Layouts of { output : string option }
  | Schemes of { output : string option }
  | Seats

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
