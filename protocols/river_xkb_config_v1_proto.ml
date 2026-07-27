(* This file was generated automatically by wayland-scanner-ocaml *)

open struct
  module Proxy = Wayland.Proxy
  module Iface_reg = Wayland.Iface_reg
  module Metadata = Wayland.Metadata
end

module River_xkb_config_v1 = struct
  type t = [`River_xkb_config_v1]
  type _ Metadata.ty += T : [`River_xkb_config_v1] Metadata.ty
  type versions = [`V1 | `V2]
  let interface = "river_xkb_config_v1"
  let version = 2l
  
  module Error = struct
    type t =
      | Invalid_destroy : t
      | Invalid_format : t
    
    let to_int32 = function
      | Invalid_destroy -> 0l
      | Invalid_format -> 1l
    
    let of_int32 = function
      | 0l -> Invalid_destroy
      | 1l -> Invalid_format
      | x -> Fmt.failwith "Invalid error enum value %ld" x
  end
  
  
  module Keymap_format = struct
    type t =
      | Text_v1 : t
      | Text_v2 : t
    
    let to_int32 = function
      | Text_v1 -> 1l
      | Text_v2 -> 2l
    
    let of_int32 = function
      | 1l -> Text_v1
      | 2l -> Text_v2
      | x -> Fmt.failwith "Invalid keymap_format enum value %ld" x
  end
  
  let requests = function
    | 0 -> "stop", []
    | 1 -> "destroy", []
    | 2 -> "create_keymap", ["id", `New_ID (Some "river_xkb_keymap_v1"); "fd", `FD; "format", `Uint]
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | 0 -> "finished", []
    | 1 -> "xkb_keyboard", ["id", `New_ID (Some "river_xkb_keyboard_v1")]
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_xkb_config_v1)

module River_xkb_keymap_v1 = struct
  type t = [`River_xkb_keymap_v1]
  type _ Metadata.ty += T : [`River_xkb_keymap_v1] Metadata.ty
  type versions = [`V1 | `V2]
  let interface = "river_xkb_keymap_v1"
  let version = 2l
  
  let requests = function
    | 0 -> "destroy", []
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | 0 -> "success", []
    | 1 -> "failure", ["error_msg", `String]
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_xkb_keymap_v1)

module River_xkb_keyboard_v1 = struct
  type t = [`River_xkb_keyboard_v1]
  type _ Metadata.ty += T : [`River_xkb_keyboard_v1] Metadata.ty
  type versions = [`V1 | `V2]
  let interface = "river_xkb_keyboard_v1"
  let version = 2l
  
  module Error = struct
    type t =
      | Invalid_keymap : t
    
    let to_int32 = function
      | Invalid_keymap -> 0l
    
    let of_int32 = function
      | 0l -> Invalid_keymap
      | x -> Fmt.failwith "Invalid error enum value %ld" x
  end
  
  let requests = function
    | 0 -> "destroy", []
    | 1 -> "set_keymap", ["keymap", `Object (Some "river_xkb_keymap_v1")]
    | 2 -> "set_layout_by_index", ["index", `Int]
    | 3 -> "set_layout_by_name", ["name", `String]
    | 4 -> "capslock_enable", []
    | 5 -> "capslock_disable", []
    | 6 -> "numlock_enable", []
    | 7 -> "numlock_disable", []
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | 0 -> "removed", []
    | 1 -> "input_device", ["device", `Object (Some "river_input_device_v1")]
    | 2 -> "layout", ["index", `Uint; "name", `String]
    | 3 -> "capslock_enabled", []
    | 4 -> "capslock_disabled", []
    | 5 -> "numlock_enabled", []
    | 6 -> "numlock_disabled", []
    | 7 -> "done", []
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_xkb_keyboard_v1)
