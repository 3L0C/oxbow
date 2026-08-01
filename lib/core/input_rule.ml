open! Ppx_yojson_conv_lib.Yojson_conv

module Send_events = struct
  type t =
    | Enabled [@name "enabled"]
    | Disabled [@name "disabled"]
    | Disabled_on_external_mouse [@name "disabled_on_external_mouse"]
  [@@deriving yojson]

  let to_string = function
    | Enabled -> "enabled"
    | Disabled -> "disabled"
    | Disabled_on_external_mouse -> "disabled-on-external-mouse"
  ;;
end

module Button_map = struct
  type t =
    | Lrm [@name "lrm"]
    | Lmr [@name "lmr"]
  [@@deriving yojson]

  let to_string = function
    | Lrm -> "left-right-middle"
    | Lmr -> "left-middle-right"
  ;;
end

module Accel_profile = struct
  type t =
    | None [@name "none"]
    | Flat [@name "flat"]
    | Adaptive [@name "adaptive"]
    | Custom [@name "custom"]
  [@@deriving yojson]

  let to_string = function
    | None -> "none"
    | Flat -> "flat"
    | Adaptive -> "adaptive"
    | Custom -> "custom"
  ;;
end

module Click_method = struct
  type t =
    | None [@name "none"]
    | Button_areas [@name "button_areas"]
    | Clickfinger [@name "clickfinger"]
  [@@deriving yojson]

  let to_string = function
    | None -> "none"
    | Button_areas -> "button-areas"
    | Clickfinger -> "clickfinger"
  ;;
end

module Scroll_method = struct
  type t =
    | No_scroll [@name "no_scroll"]
    | Two_finger [@name "two_finger"]
    | Edge [@name "edge"]
    | On_button_down [@name "on_button_down"]
  [@@deriving yojson]

  let to_string = function
    | No_scroll -> "no-scroll"
    | Two_finger -> "two-finger"
    | Edge -> "edge"
    | On_button_down -> "on-button-down"
  ;;
end

module Drag_lock = struct
  type t =
    | Disabled [@name "disabled"]
    | Enabled_timeout [@name "enabled_timeout"]
    | Enabled_sticky [@name "enabled_sticky"]
  [@@deriving yojson]

  let to_string = function
    | Disabled -> "disabled"
    | Enabled_timeout -> "enabled-timeout"
    | Enabled_sticky -> "enabled-sticky"
  ;;
end

module Three_finger_drag = struct
  type t =
    | Disabled [@name "disabled"]
    | Enabled_3fg [@name "enabled_3fg"]
    | Enabled_4fg [@name "enabled_4fg"]
  [@@deriving yojson]

  let to_string = function
    | Disabled -> "disabled"
    | Enabled_3fg -> "enabled-3fg"
    | Enabled_4fg -> "enabled-4fg"
  ;;
end

module Touchpad = struct
  type t =
    { tap : bool option [@yojson.option]
    ; tap_button_map : Button_map.t option [@yojson.option]
    ; drag : bool option [@yojson.option]
    ; drag_lock : Drag_lock.t option [@yojson.option]
    ; three_finger_drag : Three_finger_drag.t option [@yojson.option]
    ; dwt : bool option [@yojson.option]
    ; dwtp : bool option [@yojson.option]
    ; click_method : Click_method.t option [@yojson.option]
    ; clickfinger_button_map : Button_map.t option [@yojson.option]
    ; accel_profile : Accel_profile.t option [@yojson.option]
    ; accel_speed : float option [@yojson.option]
    ; natural_scroll : bool option [@yojson.option]
    ; left_handed : bool option [@yojson.option]
    ; middle_emulation : bool option [@yojson.option]
    ; scroll_method : Scroll_method.t option [@yojson.option]
    ; send_events : Send_events.t option [@yojson.option]
    ; scroll_factor : float option [@yojson.option]
    }
  [@@deriving yojson]

  let empty = Json_slots.empty t_of_yojson
  let merge = Json_slots.merge yojson_of_t t_of_yojson
end

module Mouse = struct
  type t =
    { accel_profile : Accel_profile.t option [@yojson.option]
    ; accel_speed : float option [@yojson.option]
    ; natural_scroll : bool option [@yojson.option]
    ; left_handed : bool option [@yojson.option]
    ; middle_emulation : bool option [@yojson.option]
    ; scroll_method : Scroll_method.t option [@yojson.option]
    ; scroll_button : Pointer_button.t option [@yojson.option]
    ; scroll_button_lock : bool option [@yojson.option]
    ; send_events : Send_events.t option [@yojson.option]
    ; scroll_factor : float option [@yojson.option]
    }
  [@@deriving yojson]

  let empty = Json_slots.empty t_of_yojson
  let merge = Json_slots.merge yojson_of_t t_of_yojson
end

type 'a rule =
  { pattern : string option [@yojson.option]
  ; case : Pattern.Case.t
  ; settings : 'a
  }
[@@deriving yojson]

type t =
  | Touchpad of Touchpad.t rule [@name "touchpad"]
  | Mouse of Mouse.t rule [@name "mouse"]
[@@deriving yojson]

let name_matches rule ~name = Pattern.matches ~case:rule.case ~pattern:rule.pattern name

let equal (a : t) (b : t) =
  match a, b with
  | Touchpad a', Touchpad b' -> a'.pattern = b'.pattern && a'.case = b'.case
  | Mouse a', Mouse b' -> a'.pattern = b'.pattern && a'.case = b'.case
  | _ -> false
;;
