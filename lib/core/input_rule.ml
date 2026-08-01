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

  let empty =
    { tap = None
    ; tap_button_map = None
    ; drag = None
    ; drag_lock = None
    ; three_finger_drag = None
    ; dwt = None
    ; dwtp = None
    ; click_method = None
    ; clickfinger_button_map = None
    ; accel_profile = None
    ; accel_speed = None
    ; natural_scroll = None
    ; left_handed = None
    ; middle_emulation = None
    ; scroll_method = None
    ; send_events = None
    ; scroll_factor = None
    }
  ;;

  let merge ~old ~new_ =
    let slot old_slot = function
      | None -> old_slot
      | Some _ as new_slot -> new_slot
    in
    { tap = slot old.tap new_.tap
    ; tap_button_map = slot old.tap_button_map new_.tap_button_map
    ; drag = slot old.drag new_.drag
    ; drag_lock = slot old.drag_lock new_.drag_lock
    ; three_finger_drag = slot old.three_finger_drag new_.three_finger_drag
    ; dwt = slot old.dwt new_.dwt
    ; dwtp = slot old.dwtp new_.dwtp
    ; click_method = slot old.click_method new_.click_method
    ; clickfinger_button_map = slot old.clickfinger_button_map new_.clickfinger_button_map
    ; accel_profile = slot old.accel_profile new_.accel_profile
    ; accel_speed = slot old.accel_speed new_.accel_speed
    ; natural_scroll = slot old.natural_scroll new_.natural_scroll
    ; left_handed = slot old.left_handed new_.left_handed
    ; middle_emulation = slot old.middle_emulation new_.middle_emulation
    ; scroll_method = slot old.scroll_method new_.scroll_method
    ; send_events = slot old.send_events new_.send_events
    ; scroll_factor = slot old.scroll_factor new_.scroll_factor
    }
  ;;
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

  let empty =
    { accel_profile = None
    ; accel_speed = None
    ; natural_scroll = None
    ; left_handed = None
    ; middle_emulation = None
    ; scroll_method = None
    ; scroll_button = None
    ; scroll_button_lock = None
    ; send_events = None
    ; scroll_factor = None
    }
  ;;

  let merge ~old ~new_ =
    let slot old_slot = function
      | None -> old_slot
      | Some _ as new_slot -> new_slot
    in
    { accel_profile = slot old.accel_profile new_.accel_profile
    ; accel_speed = slot old.accel_speed new_.accel_speed
    ; natural_scroll = slot old.natural_scroll new_.natural_scroll
    ; left_handed = slot old.left_handed new_.left_handed
    ; middle_emulation = slot old.middle_emulation new_.middle_emulation
    ; scroll_method = slot old.scroll_method new_.scroll_method
    ; scroll_button = slot old.scroll_button new_.scroll_button
    ; scroll_button_lock = slot old.scroll_button_lock new_.scroll_button_lock
    ; send_events = slot old.send_events new_.send_events
    ; scroll_factor = slot old.scroll_factor new_.scroll_factor
    }
  ;;
end

type 'a rule =
  { name : string option [@yojson.option]
  ; case : Pattern.Case.t
  ; settings : 'a
  }
[@@deriving yojson]

type t =
  | Touchpad of Touchpad.t rule [@name "touchpad"]
  | Mouse of Mouse.t rule [@name "mouse"]
[@@deriving yojson]

let name_matches rule ~name =
  let flags =
    match rule.case with
    | Sensitive -> []
    | Insensitive -> [ `CASELESS ]
  in
  let re_compile = function
    | None -> Ok None
    | Some s ->
      (try Ok (Some (Re.compile (Re.Pcre.re ~flags s))) with
       | Re.Pcre.(Parse_error | Not_supported) ->
         Error (Printf.sprintf "invalid regex: %s" s))
  in
  match re_compile rule.name with
  | Error msg ->
    Logs.err (fun m -> m "%s" msg);
    false
  | Ok None -> true
  | Ok (Some re) -> Re.execp re name
;;

let equal (a : t) (b : t) =
  match a, b with
  | Touchpad a', Touchpad b' -> a'.name = b'.name && a'.case = b'.case
  | Mouse a', Mouse b' -> a'.name = b'.name && a'.case = b'.case
  | _ -> false
;;
