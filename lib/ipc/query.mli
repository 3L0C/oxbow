module Layouts_reply : sig
  type t =
    { available : string list
    ; current : Record.Layout.t list
    }

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

module Seat_info : sig
  type t =
    { name : string
    ; mode : string
    ; output : string option
    }

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

type t =
  | Rules
  | Keymaps of { all : bool }
  | Outputs
  | Focused
  | Windows of { query : Ocdwm_core.Window_query.t option }
  | Tags of { output : string option }
  | Layouts of { output : string option }
  | Seats

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
