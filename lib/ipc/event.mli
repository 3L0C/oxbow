module Subscribe : sig
  type t =
    { kinds : Record.t list
    ; output : string option
    }

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
end

type t =
  | Tags of Record.Tags.t
  | Window of Record.Window.t
  | Layout of Record.Layout.t
  | Mode of Record.Mode.t
  | Focus of Record.Focus.t
  | Output of Record.Output.t

val kind : t -> Record.t
val source : t -> (string, string) result
val to_line : t -> string
