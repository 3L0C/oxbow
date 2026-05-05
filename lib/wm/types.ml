(* ocdwm types - shared type definitions *)

module Rwm = Ocdwm_protocol.River_window_management_v1_client
module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
module Xkb = Ocdwm_protocol.River_xkb_bindings_v1_client
module Tag_set = Ocdwm_core.Tag_set
open Ocdwm_core.Types
open Ocdwm_config.Types
open Ocdwm_layout.Types
open Ocdwm_ipc.Types

module Layer_focus = struct
  type t =
    | Lf_none
    | Lf_non_exclusive
    | Lf_exclusive
end

module Output_state = struct
  type t =
    | O_active
    | O_dirty of { prev : t }
    | O_removed
end

module Presentation = struct
  type t =
    | P_tiled
    | P_floating
    | P_fullscreen of { restore : [ `Tiled | `Floating ] }
end

module Pointer_position = struct
  type t =
    { x : int32
    ; y : int32
    }
end

module Seat_state = struct
  type t =
    | S_new
    | S_active
    | S_dirty of { prev : t }
    | S_closing
end

module Size_hints = struct
  type 'a t =
    { min_w : 'a
    ; max_w : 'a
    ; min_h : 'a
    ; max_h : 'a
    }
end

module Window_decoration = struct
  type t =
    | W_only_csd
    | W_prefer_csd
    | W_prefer_ssd
    | W_no_preference
end

module Window_state = struct
  type t =
    | W_new
    | W_active
    | W_dirty of { prev : t }
    | W_closing
end

module rec Output_t : sig
  type t =
    { (* Wayland objects *)
      obj : [ `V4 ] Rwm.River_output_v1.t
    ; layer_shell : [ `V1 ] Rlsh.River_layer_shell_output_v1.t
    ; (* State *)
      mutable state : Output_state.t
    ; (* Identity *)
      mutable name : string option
    ; (* Geometry *)
      mutable geom : int32 Rect.t
    ; (* Usable area *)
      mutable usable : int Rect.t
    ; (* Tag state *)
      mutable selected_tags : Tag_set.t
    ; mutable previous_tags : Tag_set.t
    ; (* Per-tag layout configuration *)
      tag_state : Tag_data.t array
    ; (* Focus stack - most recently focused first *)
      mutable focus_stack : Window_t.t list
    ; (* All windows on this output. Ordered in tiling order when filtered by
     selected_tags *)
      mutable windows : Window_t.t list
    }
end =
  Output_t

and Window_request : sig
  type t =
    | Req_move of { seat : Seat_t.t }
    | Req_resize of
        { seat : Seat_t.t
        ; edges : int32
        }
    | Req_maximize
    | Req_unmaximize
    | Req_fullscreen of { output : Output_t.t option }
    | Req_exit_fullscreen
    | Req_dimensions of
        { width : int32
        ; height : int32
        }
end =
  Window_request

and Focus_request : sig
  type t =
    | Focus_none
    | Focus_window of Window_t.t
    | Focus_clear
end =
  Focus_request

and Window_t : sig
  type t =
    { (* Wayland objects *)
      obj : [ `V4 ] Rwm.River_window_v1.t
    ; node : [ `V4 ] Rwm.River_node_v1.t
    ; (* Lifecycle *)
      mutable state : Window_state.t
    ; (* State *)
      id : int
    ; mutable app_id : string option
    ; mutable title : string option
    ; mutable identifier : string option
    ; mutable unreliable_pid : int32 option
    ; mutable parent : Window_t.t Box.t
    ; mutable decoration_hint : Window_decoration.t option
    ; mutable presentation_hint : Rwm.River_output_v1.Presentation_mode.t option
    ; (* Geometry *)
      mutable geom : int32 Rect.t
    ; mutable float_geom : int32 Rect.t option
    ; (* Size hints from dimensions_hint *)
      mutable size_hints : int32 Size_hints.t
    ; (* Tag and output assignment *)
      mutable tags : Tag_set.t
    ; mutable output : Output_t.t option
    ; (* State flags *)
      mutable is_fixed : bool
    ; mutable is_urgent : bool
    ; mutable is_maximized : bool
    ; mutable is_hidden : bool
    ; mutable presentation : Presentation.t
    ; (* Pointer op state *)
      mutable requests : Window_request.t list
    }
end =
  Window_t

and Xkb_binding : sig
  type t =
    { obj : [ `V2 ] Xkb.River_xkb_binding_v1.t
    ; seat : Seat_t.t
    ; action : Action.t
    }
end =
  Xkb_binding

and Pointer_binding : sig
  type t =
    { obj : [ `V4 ] Rwm.River_pointer_binding_v1.t
    ; seat : Seat_t.t
    ; action : Action.t
    }
end =
  Pointer_binding

and Seat_op : sig
  type t =
    | Op_none
    | Op_move of
        { window : Window_t.t
        ; start_x : int32
        ; start_y : int32
        ; mutable dx : int32
        ; mutable dy : int32
        ; mutable release : bool
        }
    | Op_resize of
        { window : Window_t.t
        ; start_x : int32
        ; start_y : int32
        ; start_w : int32
        ; start_h : int32
        ; edges : int32
        ; mutable dx : int32
        ; mutable dy : int32
        ; mutable release : bool
        }
end =
  Seat_op

and Seat_t : sig
  type t =
    { (* Wayland objects *)
      obj : [ `V4 ] Rwm.River_seat_v1.t
    ; layer_shell : [ `V1 ] Rlsh.River_layer_shell_seat_v1.t
    ; (* Lifecycle *)
      mutable state : Seat_state.t
    ; (* State *)
      mutable output : Output_t.t option
    ; mutable position : Pointer_position.t
    ; mutable layer_focus : Layer_focus.t
    ; (* Keybindings *)
      mutable xkb_bindings : Xkb_binding.t list
    ; mutable pointer_bindings : Pointer_binding.t list
    ; mutable pending_action : Action.t
    ; (* Pointer state *)
      mutable hovered : Window_t.t option
    ; mutable interacted : Window_t.t option
    ; mutable focus_request : Focus_request.t
    ; mutable cursor_target : Window_t.t option
    ; (* Interactive op state *)
      mutable op : Seat_op.t
    }
end =
  Seat_t

and Window_manager_t : sig
  type t =
    { (* Wayland objects *)
      river_wm_v1 : [ `V4 ] Rwm.River_window_manager_v1.t
    ; river_xkb_v1 : [ `V2 ] Xkb.River_xkb_bindings_v1.t
    ; river_lsh_v1 : [ `V1 ] Rlsh.River_layer_shell_v1.t
    ; registry : Wayland.Registry.t
    ; (* State *)
      mutable focused_output : Output_t.t option
    ; mutable dirty : bool
    ; (* Managed items *)
      mutable outputs : Output_t.t list (* Sorted by focus order *)
    ; mutable windows : Window_t.t list
    ; mutable seats : Seat_t.t list
    ; (* User configuration *)
      config : Config_t.t
    ; mutable config_loaded : bool
    ; (* Layout registry *)
      layout_registry : Layout_registry.t
    ; (* IPC state *)
      ipc : Ipc_state.t
    }
end =
  Window_manager_t

and Box : sig
  type 'a t = { mutable body : 'a option }
end =
  Box

and Any_box : sig
  type t =
    | Output_box of Output_t.t Box.t
    | Window_box of Window_t.t Box.t
    | Wm_box of Window_manager_t.t Box.t
    | Seat_box of Seat_t.t Box.t
end =
  Any_box

type (_, _) Wayland.S.user_data +=
  | Boxed_data of Any_box.t
  | Output_data of Output_t.t
  | Window_data of Window_t.t
  | Seat_data of Seat_t.t
