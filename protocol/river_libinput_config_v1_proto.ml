(* This file was generated automatically by wayland-scanner-ocaml *)

open struct
  module Proxy = Wayland.Proxy
  module Iface_reg = Wayland.Iface_reg
  module Metadata = Wayland.Metadata
end

module River_libinput_config_v1 = struct
  type t = [ `River_libinput_config_v1 ]
  type _ Metadata.ty += T : [ `River_libinput_config_v1 ] Metadata.ty

  type versions =
    [ `V1
    | `V2
    ]

  let interface = "river_libinput_config_v1"
  let version = 2l

  module Error = struct
    type t =
      | Invalid_arg : t
      | Invalid_destroy : t

    let to_int32 = function
      | Invalid_arg -> 0l
      | Invalid_destroy -> 1l
    ;;

    let of_int32 = function
      | 0l -> Invalid_arg
      | 1l -> Invalid_destroy
      | x -> Fmt.failwith "Invalid error enum value %ld" x
    ;;
  end

  let requests = function
    | 0 -> "stop", []
    | 1 -> "destroy", []
    | 2 ->
      ( "create_accel_config"
      , [ "id", `New_ID (Some "river_libinput_accel_config_v1"); "profile", `Uint ] )
    | i -> Proxy.unknown_request i, []
  ;;

  let events = function
    | 0 -> "finished", []
    | 1 -> "libinput_device", [ "id", `New_ID (Some "river_libinput_device_v1") ]
    | i -> Proxy.unknown_event i, []
  ;;
end

let () = Iface_reg.register (module River_libinput_config_v1)

module River_libinput_device_v1 = struct
  type t = [ `River_libinput_device_v1 ]
  type _ Metadata.ty += T : [ `River_libinput_device_v1 ] Metadata.ty

  type versions =
    [ `V1
    | `V2
    ]

  let interface = "river_libinput_device_v1"
  let version = 2l

  module Error = struct
    type t = Invalid_arg : t

    let to_int32 = function
      | Invalid_arg -> 0l
    ;;

    let of_int32 = function
      | 0l -> Invalid_arg
      | x -> Fmt.failwith "Invalid error enum value %ld" x
    ;;
  end

  module Send_events_modes = struct
    type t = int32

    let enabled = 0l
    let disabled = 1l
    let disabled_on_external_mouse = 2l
    let to_int32 = Fun.id
    let of_int32 = Fun.id
  end

  module Tap_state = struct
    type t =
      | Disabled : t
      | Enabled : t

    let to_int32 = function
      | Disabled -> 0l
      | Enabled -> 1l
    ;;

    let of_int32 = function
      | 0l -> Disabled
      | 1l -> Enabled
      | x -> Fmt.failwith "Invalid tap_state enum value %ld" x
    ;;
  end

  module Tap_button_map = struct
    type t =
      | Lrm : t
      | Lmr : t

    let to_int32 = function
      | Lrm -> 0l
      | Lmr -> 1l
    ;;

    let of_int32 = function
      | 0l -> Lrm
      | 1l -> Lmr
      | x -> Fmt.failwith "Invalid tap_button_map enum value %ld" x
    ;;
  end

  module Drag_state = struct
    type t =
      | Disabled : t
      | Enabled : t

    let to_int32 = function
      | Disabled -> 0l
      | Enabled -> 1l
    ;;

    let of_int32 = function
      | 0l -> Disabled
      | 1l -> Enabled
      | x -> Fmt.failwith "Invalid drag_state enum value %ld" x
    ;;
  end

  module Drag_lock_state = struct
    type t =
      | Disabled : t
      | Enabled_timeout : t
      | Enabled_sticky : t

    let to_int32 = function
      | Disabled -> 0l
      | Enabled_timeout -> 1l
      | Enabled_sticky -> 2l
    ;;

    let of_int32 = function
      | 0l -> Disabled
      | 1l -> Enabled_timeout
      | 2l -> Enabled_sticky
      | x -> Fmt.failwith "Invalid drag_lock_state enum value %ld" x
    ;;
  end

  module Three_finger_drag_state = struct
    type t =
      | Disabled : t
      | Enabled_3fg : t
      | Enabled_4fg : t

    let to_int32 = function
      | Disabled -> 0l
      | Enabled_3fg -> 1l
      | Enabled_4fg -> 2l
    ;;

    let of_int32 = function
      | 0l -> Disabled
      | 1l -> Enabled_3fg
      | 2l -> Enabled_4fg
      | x -> Fmt.failwith "Invalid three_finger_drag_state enum value %ld" x
    ;;
  end

  module Accel_profile = struct
    type t =
      | None : t
      | Flat : t
      | Adaptive : t
      | Custom : t

    let to_int32 = function
      | None -> 0l
      | Flat -> 1l
      | Adaptive -> 2l
      | Custom -> 4l
    ;;

    let of_int32 = function
      | 0l -> None
      | 1l -> Flat
      | 2l -> Adaptive
      | 4l -> Custom
      | x -> Fmt.failwith "Invalid accel_profile enum value %ld" x
    ;;
  end

  module Accel_profiles = struct
    type t = int32

    let none = 0l
    let flat = 1l
    let adaptive = 2l
    let custom = 4l
    let to_int32 = Fun.id
    let of_int32 = Fun.id
  end

  module Natural_scroll_state = struct
    type t =
      | Disabled : t
      | Enabled : t

    let to_int32 = function
      | Disabled -> 0l
      | Enabled -> 1l
    ;;

    let of_int32 = function
      | 0l -> Disabled
      | 1l -> Enabled
      | x -> Fmt.failwith "Invalid natural_scroll_state enum value %ld" x
    ;;
  end

  module Left_handed_state = struct
    type t =
      | Disabled : t
      | Enabled : t

    let to_int32 = function
      | Disabled -> 0l
      | Enabled -> 1l
    ;;

    let of_int32 = function
      | 0l -> Disabled
      | 1l -> Enabled
      | x -> Fmt.failwith "Invalid left_handed_state enum value %ld" x
    ;;
  end

  module Click_method = struct
    type t =
      | None : t
      | Button_areas : t
      | Clickfinger : t

    let to_int32 = function
      | None -> 0l
      | Button_areas -> 1l
      | Clickfinger -> 2l
    ;;

    let of_int32 = function
      | 0l -> None
      | 1l -> Button_areas
      | 2l -> Clickfinger
      | x -> Fmt.failwith "Invalid click_method enum value %ld" x
    ;;
  end

  module Click_methods = struct
    type t = int32

    let none = 0l
    let button_areas = 1l
    let clickfinger = 2l
    let to_int32 = Fun.id
    let of_int32 = Fun.id
  end

  module Clickfinger_button_map = struct
    type t =
      | Lrm : t
      | Lmr : t

    let to_int32 = function
      | Lrm -> 0l
      | Lmr -> 1l
    ;;

    let of_int32 = function
      | 0l -> Lrm
      | 1l -> Lmr
      | x -> Fmt.failwith "Invalid clickfinger_button_map enum value %ld" x
    ;;
  end

  module Middle_emulation_state = struct
    type t =
      | Disabled : t
      | Enabled : t

    let to_int32 = function
      | Disabled -> 0l
      | Enabled -> 1l
    ;;

    let of_int32 = function
      | 0l -> Disabled
      | 1l -> Enabled
      | x -> Fmt.failwith "Invalid middle_emulation_state enum value %ld" x
    ;;
  end

  module Scroll_method = struct
    type t =
      | No_scroll : t
      | Two_finger : t
      | Edge : t
      | On_button_down : t

    let to_int32 = function
      | No_scroll -> 0l
      | Two_finger -> 1l
      | Edge -> 2l
      | On_button_down -> 4l
    ;;

    let of_int32 = function
      | 0l -> No_scroll
      | 1l -> Two_finger
      | 2l -> Edge
      | 4l -> On_button_down
      | x -> Fmt.failwith "Invalid scroll_method enum value %ld" x
    ;;
  end

  module Scroll_methods = struct
    type t = int32

    let no_scroll = 0l
    let two_finger = 1l
    let edge = 2l
    let on_button_down = 4l
    let to_int32 = Fun.id
    let of_int32 = Fun.id
  end

  module Scroll_button_lock_state = struct
    type t =
      | Disabled : t
      | Enabled : t

    let to_int32 = function
      | Disabled -> 0l
      | Enabled -> 1l
    ;;

    let of_int32 = function
      | 0l -> Disabled
      | 1l -> Enabled
      | x -> Fmt.failwith "Invalid scroll_button_lock_state enum value %ld" x
    ;;
  end

  module Dwt_state = struct
    type t =
      | Disabled : t
      | Enabled : t

    let to_int32 = function
      | Disabled -> 0l
      | Enabled -> 1l
    ;;

    let of_int32 = function
      | 0l -> Disabled
      | 1l -> Enabled
      | x -> Fmt.failwith "Invalid dwt_state enum value %ld" x
    ;;
  end

  module Dwtp_state = struct
    type t =
      | Disabled : t
      | Enabled : t

    let to_int32 = function
      | Disabled -> 0l
      | Enabled -> 1l
    ;;

    let of_int32 = function
      | 0l -> Disabled
      | 1l -> Enabled
      | x -> Fmt.failwith "Invalid dwtp_state enum value %ld" x
    ;;
  end

  let requests = function
    | 0 -> "destroy", []
    | 1 ->
      ( "set_send_events"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "mode", `Uint ] )
    | 2 ->
      "set_tap", [ "result", `New_ID (Some "river_libinput_result_v1"); "state", `Uint ]
    | 3 ->
      ( "set_tap_button_map"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "button_map", `Uint ] )
    | 4 ->
      "set_drag", [ "result", `New_ID (Some "river_libinput_result_v1"); "state", `Uint ]
    | 5 ->
      ( "set_drag_lock"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "state", `Uint ] )
    | 6 ->
      ( "set_three_finger_drag"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "state", `Uint ] )
    | 7 ->
      ( "set_calibration_matrix"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "matrix", `Array ] )
    | 8 ->
      ( "set_accel_profile"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "profile", `Uint ] )
    | 9 ->
      ( "set_accel_speed"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "speed", `Array ] )
    | 10 ->
      ( "apply_accel_config"
      , [ "result", `New_ID (Some "river_libinput_result_v1")
        ; "config", `Object (Some "river_libinput_accel_config_v1")
        ] )
    | 11 ->
      ( "set_natural_scroll"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "state", `Uint ] )
    | 12 ->
      ( "set_left_handed"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "state", `Uint ] )
    | 13 ->
      ( "set_click_method"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "method", `Uint ] )
    | 14 ->
      ( "set_clickfinger_button_map"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "button_map", `Uint ] )
    | 15 ->
      ( "set_middle_emulation"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "state", `Uint ] )
    | 16 ->
      ( "set_scroll_method"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "method", `Uint ] )
    | 17 ->
      ( "set_scroll_button"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "button", `Uint ] )
    | 18 ->
      ( "set_scroll_button_lock"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "state", `Uint ] )
    | 19 ->
      "set_dwt", [ "result", `New_ID (Some "river_libinput_result_v1"); "state", `Uint ]
    | 20 ->
      "set_dwtp", [ "result", `New_ID (Some "river_libinput_result_v1"); "state", `Uint ]
    | 21 ->
      ( "set_rotation"
      , [ "result", `New_ID (Some "river_libinput_result_v1"); "angle", `Uint ] )
    | i -> Proxy.unknown_request i, []
  ;;

  let events = function
    | 0 -> "removed", []
    | 1 -> "input_device", [ "device", `Object (Some "river_input_device_v1") ]
    | 2 -> "send_events_support", [ "modes", `Uint ]
    | 3 -> "send_events_default", [ "mode", `Uint ]
    | 4 -> "send_events_current", [ "mode", `Uint ]
    | 5 -> "tap_support", [ "finger_count", `Int ]
    | 6 -> "tap_default", [ "state", `Uint ]
    | 7 -> "tap_current", [ "state", `Uint ]
    | 8 -> "tap_button_map_default", [ "button_map", `Uint ]
    | 9 -> "tap_button_map_current", [ "button_map", `Uint ]
    | 10 -> "drag_default", [ "state", `Uint ]
    | 11 -> "drag_current", [ "state", `Uint ]
    | 12 -> "drag_lock_default", [ "state", `Uint ]
    | 13 -> "drag_lock_current", [ "state", `Uint ]
    | 14 -> "three_finger_drag_support", [ "finger_count", `Int ]
    | 15 -> "three_finger_drag_default", [ "state", `Uint ]
    | 16 -> "three_finger_drag_current", [ "state", `Uint ]
    | 17 -> "calibration_matrix_support", [ "supported", `Int ]
    | 18 -> "calibration_matrix_default", [ "matrix", `Array ]
    | 19 -> "calibration_matrix_current", [ "matrix", `Array ]
    | 20 -> "accel_profiles_support", [ "profiles", `Uint ]
    | 21 -> "accel_profile_default", [ "profile", `Uint ]
    | 22 -> "accel_profile_current", [ "profile", `Uint ]
    | 23 -> "accel_speed_default", [ "speed", `Array ]
    | 24 -> "accel_speed_current", [ "speed", `Array ]
    | 25 -> "natural_scroll_support", [ "supported", `Int ]
    | 26 -> "natural_scroll_default", [ "state", `Uint ]
    | 27 -> "natural_scroll_current", [ "state", `Uint ]
    | 28 -> "left_handed_support", [ "supported", `Int ]
    | 29 -> "left_handed_default", [ "state", `Uint ]
    | 30 -> "left_handed_current", [ "state", `Uint ]
    | 31 -> "click_method_support", [ "methods", `Uint ]
    | 32 -> "click_method_default", [ "method", `Uint ]
    | 33 -> "click_method_current", [ "method", `Uint ]
    | 34 -> "clickfinger_button_map_default", [ "button_map", `Uint ]
    | 35 -> "clickfinger_button_map_current", [ "button_map", `Uint ]
    | 36 -> "middle_emulation_support", [ "supported", `Int ]
    | 37 -> "middle_emulation_default", [ "state", `Uint ]
    | 38 -> "middle_emulation_current", [ "state", `Uint ]
    | 39 -> "scroll_method_support", [ "methods", `Uint ]
    | 40 -> "scroll_method_default", [ "method", `Uint ]
    | 41 -> "scroll_method_current", [ "method", `Uint ]
    | 42 -> "scroll_button_default", [ "button", `Uint ]
    | 43 -> "scroll_button_current", [ "button", `Uint ]
    | 44 -> "scroll_button_lock_default", [ "state", `Uint ]
    | 45 -> "scroll_button_lock_current", [ "state", `Uint ]
    | 46 -> "dwt_support", [ "supported", `Int ]
    | 47 -> "dwt_default", [ "state", `Uint ]
    | 48 -> "dwt_current", [ "state", `Uint ]
    | 49 -> "dwtp_support", [ "supported", `Int ]
    | 50 -> "dwtp_default", [ "state", `Uint ]
    | 51 -> "dwtp_current", [ "state", `Uint ]
    | 52 -> "rotation_support", [ "supported", `Int ]
    | 53 -> "rotation_default", [ "angle", `Uint ]
    | 54 -> "rotation_current", [ "angle", `Uint ]
    | 55 -> "done", []
    | i -> Proxy.unknown_event i, []
  ;;
end

let () = Iface_reg.register (module River_libinput_device_v1)

module River_libinput_accel_config_v1 = struct
  type t = [ `River_libinput_accel_config_v1 ]
  type _ Metadata.ty += T : [ `River_libinput_accel_config_v1 ] Metadata.ty
  type versions = [ `V1 ]

  let interface = "river_libinput_accel_config_v1"
  let version = 1l

  module Error = struct
    type t = Invalid_arg : t

    let to_int32 = function
      | Invalid_arg -> 0l
    ;;

    let of_int32 = function
      | 0l -> Invalid_arg
      | x -> Fmt.failwith "Invalid error enum value %ld" x
    ;;
  end

  module Accel_type = struct
    type t =
      | Fallback : t
      | Motion : t
      | Scroll : t

    let to_int32 = function
      | Fallback -> 0l
      | Motion -> 1l
      | Scroll -> 2l
    ;;

    let of_int32 = function
      | 0l -> Fallback
      | 1l -> Motion
      | 2l -> Scroll
      | x -> Fmt.failwith "Invalid accel_type enum value %ld" x
    ;;
  end

  let requests = function
    | 0 -> "destroy", []
    | 1 ->
      ( "set_points"
      , [ "result", `New_ID (Some "river_libinput_result_v1")
        ; "type", `Uint
        ; "step", `Array
        ; "points", `Array
        ] )
    | i -> Proxy.unknown_request i, []
  ;;

  let events = function
    | i -> Proxy.unknown_event i, []
  ;;
end

let () = Iface_reg.register (module River_libinput_accel_config_v1)

module River_libinput_result_v1 = struct
  type t = [ `River_libinput_result_v1 ]
  type _ Metadata.ty += T : [ `River_libinput_result_v1 ] Metadata.ty
  type versions = [ `V1 ]

  let interface = "river_libinput_result_v1"
  let version = 1l

  let requests = function
    | i -> Proxy.unknown_request i, []
  ;;

  let events = function
    | 0 -> "success", []
    | 1 -> "unsupported", []
    | 2 -> "invalid", []
    | i -> Proxy.unknown_event i, []
  ;;
end

let () = Iface_reg.register (module River_libinput_result_v1)
