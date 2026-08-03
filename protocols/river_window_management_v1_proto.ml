(* This file was generated automatically by wayland-scanner-ocaml *)

open struct
  module Proxy = Wayland.Proxy
  module Iface_reg = Wayland.Iface_reg
  module Metadata = Wayland.Metadata
end

module River_window_manager_v1 = struct
  type t = [`River_window_manager_v1]
  type _ Metadata.ty += T : [`River_window_manager_v1] Metadata.ty
  type versions = [`V1 | `V2 | `V3 | `V4 | `V5]
  let interface = "river_window_manager_v1"
  let version = 5l
  
  module Error = struct
    type t =
      | Sequence_order : t
      | Role : t
      | Unresponsive : t
    
    let to_int32 = function
      | Sequence_order -> 0l
      | Role -> 1l
      | Unresponsive -> 2l
    
    let of_int32 = function
      | 0l -> Sequence_order
      | 1l -> Role
      | 2l -> Unresponsive
      | x -> Fmt.failwith "Invalid error enum value %ld" x
  end
  
  let requests = function
    | 0 -> "stop", []
    | 1 -> "destroy", []
    | 2 -> "manage_finish", []
    | 3 -> "manage_dirty", []
    | 4 -> "render_finish", []
    | 5 -> "get_shell_surface", ["id", `New_ID (Some "river_shell_surface_v1"); "surface", `Object (Some "wl_surface")]
    | 6 -> "exit_session", []
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | 0 -> "unavailable", []
    | 1 -> "finished", []
    | 2 -> "manage_start", []
    | 3 -> "render_start", []
    | 4 -> "session_locked", []
    | 5 -> "session_unlocked", []
    | 6 -> "window", ["id", `New_ID (Some "river_window_v1")]
    | 7 -> "output", ["id", `New_ID (Some "river_output_v1")]
    | 8 -> "seat", ["id", `New_ID (Some "river_seat_v1")]
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_window_manager_v1)

module River_window_v1 = struct
  type t = [`River_window_v1]
  type _ Metadata.ty += T : [`River_window_v1] Metadata.ty
  type versions = [`V1 | `V2 | `V3 | `V4 | `V5]
  let interface = "river_window_v1"
  let version = 5l
  
  module Error = struct
    type t =
      | Node_exists : t
      | Invalid_dimensions : t
      | Invalid_border : t
      | Invalid_clip_box : t
    
    let to_int32 = function
      | Node_exists -> 0l
      | Invalid_dimensions -> 1l
      | Invalid_border -> 2l
      | Invalid_clip_box -> 3l
    
    let of_int32 = function
      | 0l -> Node_exists
      | 1l -> Invalid_dimensions
      | 2l -> Invalid_border
      | 3l -> Invalid_clip_box
      | x -> Fmt.failwith "Invalid error enum value %ld" x
  end
  
  
  module Decoration_hint = struct
    type t =
      | Only_supports_csd : t
      | Prefers_csd : t
      | Prefers_ssd : t
      | No_preference : t
    
    let to_int32 = function
      | Only_supports_csd -> 0l
      | Prefers_csd -> 1l
      | Prefers_ssd -> 2l
      | No_preference -> 3l
    
    let of_int32 = function
      | 0l -> Only_supports_csd
      | 1l -> Prefers_csd
      | 2l -> Prefers_ssd
      | 3l -> No_preference
      | x -> Fmt.failwith "Invalid decoration_hint enum value %ld" x
  end
  
  
  module Edges = struct
    type t = int32
    
    let none = 0l
    
    let top = 1l
    
    let bottom = 2l
    
    let left = 4l
    
    let right = 8l
    
    let to_int32 = Fun.id
    let of_int32 = Fun.id
  end
  
  
  module Capabilities = struct
    type t = int32
    
    let window_menu = 1l
    
    let maximize = 2l
    
    let fullscreen = 4l
    
    let minimize = 8l
    
    let to_int32 = Fun.id
    let of_int32 = Fun.id
  end
  
  let requests = function
    | 0 -> "destroy", []
    | 1 -> "close", []
    | 2 -> "get_node", ["id", `New_ID (Some "river_node_v1")]
    | 3 -> "propose_dimensions", ["width", `Int; "height", `Int]
    | 4 -> "hide", []
    | 5 -> "show", []
    | 6 -> "use_csd", []
    | 7 -> "use_ssd", []
    | 8 -> "set_borders", ["edges", `Uint; "width", `Int; "r", `Uint; "g", `Uint; "b", `Uint; "a", `Uint]
    | 9 -> "set_tiled", ["edges", `Uint]
    | 10 -> "get_decoration_above", ["id", `New_ID (Some "river_decoration_v1"); "surface", `Object (Some "wl_surface")]
    | 11 -> "get_decoration_below", ["id", `New_ID (Some "river_decoration_v1"); "surface", `Object (Some "wl_surface")]
    | 12 -> "inform_resize_start", []
    | 13 -> "inform_resize_end", []
    | 14 -> "set_capabilities", ["caps", `Uint]
    | 15 -> "inform_maximized", []
    | 16 -> "inform_unmaximized", []
    | 17 -> "inform_fullscreen", []
    | 18 -> "inform_not_fullscreen", []
    | 19 -> "fullscreen", ["output", `Object (Some "river_output_v1")]
    | 20 -> "exit_fullscreen", []
    | 21 -> "set_clip_box", ["x", `Int; "y", `Int; "width", `Int; "height", `Int]
    | 22 -> "set_content_clip_box", ["x", `Int; "y", `Int; "width", `Int; "height", `Int]
    | 23 -> "set_dimension_bounds", ["max_width", `Int; "max_height", `Int]
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | 0 -> "closed", []
    | 1 -> "dimensions_hint", ["min_width", `Int; "min_height", `Int; "max_width", `Int; "max_height", `Int]
    | 2 -> "dimensions", ["width", `Int; "height", `Int]
    | 3 -> "app_id", ["app_id", `String]
    | 4 -> "title", ["title", `String]
    | 5 -> "parent", ["parent", `Object (Some "river_window_v1")]
    | 6 -> "decoration_hint", ["hint", `Uint]
    | 7 -> "pointer_move_requested", ["seat", `Object (Some "river_seat_v1")]
    | 8 -> "pointer_resize_requested", ["seat", `Object (Some "river_seat_v1"); "edges", `Uint]
    | 9 -> "show_window_menu_requested", ["x", `Int; "y", `Int]
    | 10 -> "maximize_requested", []
    | 11 -> "unmaximize_requested", []
    | 12 -> "fullscreen_requested", ["output", `Object (Some "river_output_v1")]
    | 13 -> "exit_fullscreen_requested", []
    | 14 -> "minimize_requested", []
    | 15 -> "unreliable_pid", ["unreliable_pid", `Int]
    | 16 -> "presentation_hint", ["hint", `Uint]
    | 17 -> "identifier", ["identifier", `String]
    | 18 -> "capture_sessions", ["count", `Uint]
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_window_v1)

module River_decoration_v1 = struct
  type t = [`River_decoration_v1]
  type _ Metadata.ty += T : [`River_decoration_v1] Metadata.ty
  type versions = [`V1 | `V2 | `V3 | `V4 | `V5]
  let interface = "river_decoration_v1"
  let version = 5l
  
  module Error = struct
    type t =
      | No_commit : t
    
    let to_int32 = function
      | No_commit -> 0l
    
    let of_int32 = function
      | 0l -> No_commit
      | x -> Fmt.failwith "Invalid error enum value %ld" x
  end
  
  let requests = function
    | 0 -> "destroy", []
    | 1 -> "set_offset", ["x", `Int; "y", `Int]
    | 2 -> "sync_next_commit", []
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_decoration_v1)

module River_shell_surface_v1 = struct
  type t = [`River_shell_surface_v1]
  type _ Metadata.ty += T : [`River_shell_surface_v1] Metadata.ty
  type versions = [`V1 | `V2 | `V3 | `V4 | `V5]
  let interface = "river_shell_surface_v1"
  let version = 5l
  
  module Error = struct
    type t =
      | Node_exists : t
      | No_commit : t
    
    let to_int32 = function
      | Node_exists -> 0l
      | No_commit -> 1l
    
    let of_int32 = function
      | 0l -> Node_exists
      | 1l -> No_commit
      | x -> Fmt.failwith "Invalid error enum value %ld" x
  end
  
  let requests = function
    | 0 -> "destroy", []
    | 1 -> "get_node", ["id", `New_ID (Some "river_node_v1")]
    | 2 -> "sync_next_commit", []
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_shell_surface_v1)

module River_node_v1 = struct
  type t = [`River_node_v1]
  type _ Metadata.ty += T : [`River_node_v1] Metadata.ty
  type versions = [`V1 | `V2 | `V3 | `V4 | `V5]
  let interface = "river_node_v1"
  let version = 5l
  
  let requests = function
    | 0 -> "destroy", []
    | 1 -> "set_position", ["x", `Int; "y", `Int]
    | 2 -> "place_top", []
    | 3 -> "place_bottom", []
    | 4 -> "place_above", ["other", `Object (Some "river_node_v1")]
    | 5 -> "place_below", ["other", `Object (Some "river_node_v1")]
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_node_v1)

module River_output_v1 = struct
  type t = [`River_output_v1]
  type _ Metadata.ty += T : [`River_output_v1] Metadata.ty
  type versions = [`V1 | `V2 | `V3 | `V4 | `V5]
  let interface = "river_output_v1"
  let version = 5l
  
  module Error = struct
    type t =
      | Invalid_presentation_mode : t
    
    let to_int32 = function
      | Invalid_presentation_mode -> 0l
    
    let of_int32 = function
      | 0l -> Invalid_presentation_mode
      | x -> Fmt.failwith "Invalid error enum value %ld" x
  end
  
  
  module Presentation_mode = struct
    type t =
      | Vsync : t
        (** Tearing-free presentation.
            
            Output page-flips should be synchronized to the vertical blanking
            period, eliminating tearing. This is the default presentation mode. *)
      | Async : t
        (** Asynchronous presentation.
            
            Output page-flips should not be synchronized to the vertical blanking
            period, visual screen tearing may occur. *)
    
    let to_int32 = function
      | Vsync -> 0l
      | Async -> 1l
    
    let of_int32 = function
      | 0l -> Vsync
      | 1l -> Async
      | x -> Fmt.failwith "Invalid presentation_mode enum value %ld" x
  end
  
  let requests = function
    | 0 -> "destroy", []
    | 1 -> "set_presentation_mode", ["mode", `Uint]
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | 0 -> "removed", []
    | 1 -> "wl_output", ["name", `Uint]
    | 2 -> "position", ["x", `Int; "y", `Int]
    | 3 -> "dimensions", ["width", `Int; "height", `Int]
    | 4 -> "capture_sessions", ["count", `Uint]
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_output_v1)

module River_seat_v1 = struct
  type t = [`River_seat_v1]
  type _ Metadata.ty += T : [`River_seat_v1] Metadata.ty
  type versions = [`V1 | `V2 | `V3 | `V4 | `V5]
  let interface = "river_seat_v1"
  let version = 5l
  
  (** A set of keyboard modifiers.
      
      This enum is used to describe the keyboard modifiers that must be held
      down to trigger a key binding or pointer binding.
      
      Note that river and wlroots use the values 2 and 16 for capslock and
      numlock internally. It doesn't make sense to use locked modifiers for
      bindings however so these values are not included in this enum. *)
  module Modifiers = struct
    type t = int32
    
    let none = 0l
    
    let shift = 1l
    
    let ctrl = 4l
    
    let mod1 = 8l
    
    let mod3 = 32l
    
    let mod4 = 64l
    
    let mod5 = 128l
    
    let to_int32 = Fun.id
    let of_int32 = Fun.id
  end
  
  let requests = function
    | 0 -> "destroy", []
    | 1 -> "focus_window", ["window", `Object (Some "river_window_v1")]
    | 2 -> "focus_shell_surface", ["shell_surface", `Object (Some "river_shell_surface_v1")]
    | 3 -> "clear_focus", []
    | 4 -> "op_start_pointer", []
    | 5 -> "op_end", []
    | 6 -> "get_pointer_binding", ["id", `New_ID (Some "river_pointer_binding_v1"); "button", `Uint; "modifiers", `Uint]
    | 7 -> "set_xcursor_theme", ["name", `String; "size", `Uint]
    | 8 -> "pointer_warp", ["x", `Int; "y", `Int]
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | 0 -> "removed", []
    | 1 -> "wl_seat", ["name", `Uint]
    | 2 -> "pointer_enter", ["window", `Object (Some "river_window_v1")]
    | 3 -> "pointer_leave", []
    | 4 -> "window_interaction", ["window", `Object (Some "river_window_v1")]
    | 5 -> "shell_surface_interaction", ["shell_surface", `Object (Some "river_shell_surface_v1")]
    | 6 -> "op_delta", ["dx", `Int; "dy", `Int]
    | 7 -> "op_release", []
    | 8 -> "pointer_position", ["x", `Int; "y", `Int]
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_seat_v1)

module River_pointer_binding_v1 = struct
  type t = [`River_pointer_binding_v1]
  type _ Metadata.ty += T : [`River_pointer_binding_v1] Metadata.ty
  type versions = [`V1 | `V2 | `V3 | `V4 | `V5]
  let interface = "river_pointer_binding_v1"
  let version = 5l
  
  let requests = function
    | 0 -> "destroy", []
    | 1 -> "enable", []
    | 2 -> "disable", []
    | i -> Proxy.unknown_request i, []
  
  let events = function
    | 0 -> "pressed", []
    | 1 -> "released", []
    | i -> Proxy.unknown_event i, []
  
end
let () = Iface_reg.register (module River_pointer_binding_v1)
