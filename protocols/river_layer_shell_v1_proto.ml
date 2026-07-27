(* This file was generated automatically by wayland-scanner-ocaml *)

open struct
  module Proxy = Wayland.Proxy
  module Iface_reg = Wayland.Iface_reg
  module Metadata = Wayland.Metadata
end

module River_layer_shell_v1 = struct
  type t = [`River_layer_shell_v1]
  type _ Metadata.ty += T : [`River_layer_shell_v1] Metadata.ty
  type versions = [`V1]
  let interface = "river_layer_shell_v1"
  let version = 1l
  
  module Error = struct
    type t =
      | Object_already_created : t
    
    let to_int32 = function
      | Object_already_created -> 0l
    
    let of_int32 = function
      | 0l -> Object_already_created
      | x -> Fmt.failwith "Invalid error enum value %ld" x
  end
  
  let requests = function
    | 0 -> "destroy", []
    | 1 -> "get_output", ["id", `New_ID (Some "river_layer_shell_output_v1");
                          "output", `Object (Some "river_output_v1")]
    | 2 -> "get_seat", ["id", `New_ID (Some "river_layer_shell_seat_v1"); "seat", `Object (Some "river_seat_v1")]
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_layer_shell_v1)

module River_layer_shell_output_v1 = struct
  type t = [`River_layer_shell_output_v1]
  type _ Metadata.ty += T : [`River_layer_shell_output_v1] Metadata.ty
  type versions = [`V1]
  let interface = "river_layer_shell_output_v1"
  let version = 1l
  
  let requests = function
    | 0 -> "destroy", []
    | 1 -> "set_default", []
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | 0 -> "non_exclusive_area", ["x", `Int; "y", `Int; "width", `Int; "height", `Int]
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_layer_shell_output_v1)

module River_layer_shell_seat_v1 = struct
  type t = [`River_layer_shell_seat_v1]
  type _ Metadata.ty += T : [`River_layer_shell_seat_v1] Metadata.ty
  type versions = [`V1]
  let interface = "river_layer_shell_seat_v1"
  let version = 1l
  
  let requests = function
    | 0 -> "destroy", []
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | 0 -> "focus_exclusive", []
    | 1 -> "focus_non_exclusive", []
    | 2 -> "focus_none", []
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_layer_shell_seat_v1)
