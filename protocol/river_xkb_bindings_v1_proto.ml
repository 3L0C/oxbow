(* This file was generated automatically by wayland-scanner-ocaml *)

open struct
  module Proxy = Wayland.Proxy
  module Iface_reg = Wayland.Iface_reg
  module Metadata = Wayland.Metadata
end

module River_xkb_bindings_v1 = struct
  type t = [ `River_xkb_bindings_v1 ]
  type _ Metadata.ty += T : [ `River_xkb_bindings_v1 ] Metadata.ty

  type versions =
    [ `V1
    | `V2
    | `V3
    ]

  let interface = "river_xkb_bindings_v1"
  let version = 3l

  module Error = struct
    type t = Object_already_created : t

    let to_int32 = function
      | Object_already_created -> 0l
    ;;

    let of_int32 = function
      | 0l -> Object_already_created
      | x -> Fmt.failwith "Invalid error enum value %ld" x
    ;;
  end

  let requests = function
    | 0 -> "destroy", []
    | 1 ->
      ( "get_xkb_binding"
      , [ "seat", `Object (Some "river_seat_v1")
        ; "id", `New_ID (Some "river_xkb_binding_v1")
        ; "keysym", `Uint
        ; "modifiers", `Uint
        ] )
    | 2 ->
      ( "get_seat"
      , [ "id", `New_ID (Some "river_xkb_bindings_seat_v1")
        ; "seat", `Object (Some "river_seat_v1")
        ] )
    | i -> Proxy.unknown_request i, []
  ;;

  let events = function
    | i -> Proxy.unknown_event i, []
  ;;
end

let () = Iface_reg.register (module River_xkb_bindings_v1)

module River_xkb_binding_v1 = struct
  type t = [ `River_xkb_binding_v1 ]
  type _ Metadata.ty += T : [ `River_xkb_binding_v1 ] Metadata.ty

  type versions =
    [ `V1
    | `V2
    | `V3
    ]

  let interface = "river_xkb_binding_v1"
  let version = 3l

  let requests = function
    | 0 -> "destroy", []
    | 1 -> "set_layout_override", [ "layout", `Uint ]
    | 2 -> "enable", []
    | 3 -> "disable", []
    | i -> Proxy.unknown_request i, []
  ;;

  let events = function
    | 0 -> "pressed", []
    | 1 -> "released", []
    | 2 -> "stop_repeat", []
    | i -> Proxy.unknown_event i, []
  ;;
end

let () = Iface_reg.register (module River_xkb_binding_v1)

module River_xkb_bindings_seat_v1 = struct
  type t = [ `River_xkb_bindings_seat_v1 ]
  type _ Metadata.ty += T : [ `River_xkb_bindings_seat_v1 ] Metadata.ty

  type versions =
    [ `V1
    | `V2
    | `V3
    ]

  let interface = "river_xkb_bindings_seat_v1"
  let version = 3l

  let requests = function
    | 0 -> "destroy", []
    | 1 -> "ensure_next_key_eaten", []
    | 2 -> "cancel_ensure_next_key_eaten", []
    | 3 -> "modifiers_watch", [ "modifiers", `Uint ]
    | i -> Proxy.unknown_request i, []
  ;;

  let events = function
    | 0 -> "ate_unbound_key", []
    | 1 -> "modifiers_update", [ "old", `Uint; "new_", `Uint ]
    | i -> Proxy.unknown_event i, []
  ;;
end

let () = Iface_reg.register (module River_xkb_bindings_seat_v1)
