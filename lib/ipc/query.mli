module Reply : sig
  module Available : sig
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

  module Input_device : sig
    type t =
      { name : string
      ; role : string
      }

    val t_of_yojson : Yojson.Safe.t -> t
    val yojson_of_t : t -> Yojson.Safe.t
  end
end

type t =
  | Focused
  | Input_devices of
      { pattern : string option
      ; case : Ocdwm_core.Pattern.Case.t
      ; role : Ocdwm_core.Input.Role.t option
      }
  | Input_rules
  | Keymaps of { all : bool }
  | Layouts of { output : string option }
  | Outputs
  | Schemes of { output : string option }
  | Seats
  | Tags of { output : string option }
  | Window_rules
  | Windows of { filter : Ocdwm_core.Window_match.t }

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
