(* This file was generated automatically by wayland-scanner-ocaml *)

open struct
  module Proxy = Wayland.Proxy
  module Iface_reg = Wayland.Iface_reg
  module Metadata = Wayland.Metadata
end

module River_input_manager_v1 = struct
  type t = [`River_input_manager_v1]
  type _ Metadata.ty += T : [`River_input_manager_v1] Metadata.ty
  type versions = [`V1 | `V2]
  let interface = "river_input_manager_v1"
  let version = 2l
  
  module Error = struct
    type t =
      | Invalid_destroy : t
    
    let to_int32 = function
      | Invalid_destroy -> 0l
    
    let of_int32 = function
      | 0l -> Invalid_destroy
      | x -> Fmt.failwith "Invalid error enum value %ld" x
  end
  
  let requests = function
    | 0 -> "stop", []
    | 1 -> "destroy", []
    | 2 -> "create_seat", ["name", `String]
    | 3 -> "destroy_seat", ["name", `String]
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | 0 -> "finished", []
    | 1 -> "input_device", ["id", `New_ID (Some "river_input_device_v1")]
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_input_manager_v1)

module River_input_device_v1 = struct
  type t = [`River_input_device_v1]
  type _ Metadata.ty += T : [`River_input_device_v1] Metadata.ty
  type versions = [`V1 | `V2]
  let interface = "river_input_device_v1"
  let version = 2l
  
  module Error = struct
    type t =
      | Invalid_repeat_info : t
      | Invalid_scroll_factor : t
      | Invalid_map_to_rectangle : t
    
    let to_int32 = function
      | Invalid_repeat_info -> 0l
      | Invalid_scroll_factor -> 1l
      | Invalid_map_to_rectangle -> 2l
    
    let of_int32 = function
      | 0l -> Invalid_repeat_info
      | 1l -> Invalid_scroll_factor
      | 2l -> Invalid_map_to_rectangle
      | x -> Fmt.failwith "Invalid error enum value %ld" x
  end
  
  
  module Type = struct
    type t =
      | Keyboard : t
      | Pointer : t
      | Touch : t
      | Tablet : t
    
    let to_int32 = function
      | Keyboard -> 0l
      | Pointer -> 1l
      | Touch -> 2l
      | Tablet -> 3l
    
    let of_int32 = function
      | 0l -> Keyboard
      | 1l -> Pointer
      | 2l -> Touch
      | 3l -> Tablet
      | x -> Fmt.failwith "Invalid type enum value %ld" x
  end
  
  let requests = function
    | 0 -> "destroy", []
    | 1 -> "assign_to_seat", ["name", `String]
    | 2 -> "set_repeat_info", ["rate", `Int; "delay", `Int]
    | 3 -> "set_scroll_factor", ["factor", `Fixed]
    | 4 -> "map_to_output", ["output", `Object (Some "wl_output")]
    | 5 -> "map_to_rectangle", ["x", `Int; "y", `Int; "width", `Int; "height", `Int]
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | 0 -> "removed", []
    | 1 -> "type", ["type", `Uint]
    | 2 -> "name", ["name", `String]
    | 3 -> "done", []
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_input_device_v1)
