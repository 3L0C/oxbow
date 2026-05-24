type key =
  | Keysym of Xkbcommon.Keysym.t
  | Pointer of Input_event.t

type t =
  { mods : int32
  ; key : key
  }

val parse_modifiers : string -> (int32, string) result
val parse_keysym : string -> (Xkbcommon.Keysym.t, string) result
val parse_button : string -> (Input_event.t, string) result
val parse : string -> (t, string) result
