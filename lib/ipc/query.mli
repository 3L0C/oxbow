module Window_info : sig
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

type t =
  | Rules
  | Keymaps of { all : bool }
  | Outputs
  | Focused
  | Windows of { query : Ocdwm_core.Window_query.t option }

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
