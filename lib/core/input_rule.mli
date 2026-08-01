module Send_events : sig
  type t =
    | Enabled
    | Disabled
    | Disabled_on_external_mouse

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
  val to_string : t -> string
end

module Button_map : sig
  type t =
    | Lrm
    | Lmr

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
  val to_string : t -> string
end

module Accel_profile : sig
  type t =
    | None
    | Flat
    | Adaptive
    | Custom

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
  val to_string : t -> string
end

module Click_method : sig
  type t =
    | None
    | Button_areas
    | Clickfinger

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
  val to_string : t -> string
end

module Scroll_method : sig
  type t =
    | No_scroll
    | Two_finger
    | Edge
    | On_button_down

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
  val to_string : t -> string
end

module Drag_lock : sig
  type t =
    | Disabled
    | Enabled_timeout
    | Enabled_sticky

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
  val to_string : t -> string
end

module Three_finger_drag : sig
  type t =
    | Disabled
    | Enabled_3fg
    | Enabled_4fg

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
  val to_string : t -> string
end

module Touchpad : sig
  type t =
    { tap : bool option
    ; tap_button_map : Button_map.t option
    ; drag : bool option
    ; drag_lock : Drag_lock.t option
    ; three_finger_drag : Three_finger_drag.t option
    ; dwt : bool option
    ; dwtp : bool option
    ; click_method : Click_method.t option
    ; clickfinger_button_map : Button_map.t option
    ; accel_profile : Accel_profile.t option
    ; accel_speed : float option
    ; natural_scroll : bool option
    ; left_handed : bool option
    ; middle_emulation : bool option
    ; scroll_method : Scroll_method.t option
    ; send_events : Send_events.t option
    ; scroll_factor : float option
    }

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
  val empty : t
  val merge : old:t -> new_:t -> t
end

module Mouse : sig
  type t =
    { accel_profile : Accel_profile.t option
    ; accel_speed : float option
    ; natural_scroll : bool option
    ; left_handed : bool option
    ; middle_emulation : bool option
    ; scroll_method : Scroll_method.t option
    ; scroll_button : Pointer_button.t option
    ; scroll_button_lock : bool option
    ; send_events : Send_events.t option
    ; scroll_factor : float option
    }

  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
  val empty : t
  val merge : old:t -> new_:t -> t
end

type 'a rule =
  { name : string option
  ; case : Pattern.Case.t
  ; settings : 'a
  }

val rule_of_yojson : (Yojson.Safe.t -> 'a) -> Yojson.Safe.t -> 'a rule
val yojson_of_rule : ('a -> Yojson.Safe.t) -> 'a rule -> Yojson.Safe.t

type t =
  | Touchpad of Touchpad.t rule
  | Mouse of Mouse.t rule

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
val name_matches : 'a rule -> name:string -> bool
val equal : t -> t -> bool
