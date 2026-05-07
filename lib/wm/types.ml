module Rwm = Ocdwm_protocol.River_window_management_v1_client
module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
module Xkb = Ocdwm_protocol.River_xkb_bindings_v1_client
open! Ocdwm_core

module rec Output : sig
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
      mutable focus_stack : Window.t list
    ; (* All windows on this output. Ordered in tiling order when filtered by
     selected_tags *)
      mutable windows : Window.t list
    }
end =
  Output

and Window_request : sig
  type t =
    | Req_move of { seat : Seat.t }
    | Req_resize of
        { seat : Seat.t
        ; edges : int32
        }
    | Req_maximize
    | Req_unmaximize
    | Req_fullscreen of { output : Output.t option }
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
    | Focus_window of Window.t
    | Focus_clear
end =
  Focus_request

and Window : sig
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
    ; mutable parent : Window.t Box.t
    ; mutable decoration_hint : Window_decoration.t option
    ; mutable presentation_hint : Rwm.River_output_v1.Presentation_mode.t option
    ; (* Geometry *)
      mutable geom : int32 Rect.t
    ; mutable float_geom : int32 Rect.t option
    ; (* Size hints from dimensions_hint *)
      mutable size_hints : int32 Size_hints.t
    ; (* Tag and output assignment *)
      mutable tags : Tag_set.t
    ; mutable output : Output.t option
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
  Window

and Xkb_binding : sig
  type t =
    { obj : [ `V2 ] Xkb.River_xkb_binding_v1.t
    ; seat : Seat.t
    ; action : Action.t
    }
end =
  Xkb_binding

and Pointer_binding : sig
  type t =
    { obj : [ `V4 ] Rwm.River_pointer_binding_v1.t
    ; seat : Seat.t
    ; action : Action.t
    }
end =
  Pointer_binding

and Seat_op : sig
  type t =
    | Op_none
    | Op_move of
        { window : Window.t
        ; start_x : int32
        ; start_y : int32
        ; mutable dx : int32
        ; mutable dy : int32
        ; mutable release : bool
        }
    | Op_resize of
        { window : Window.t
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

and Seat : sig
  type t =
    { (* Wayland objects *)
      obj : [ `V4 ] Rwm.River_seat_v1.t
    ; layer_shell : [ `V1 ] Rlsh.River_layer_shell_seat_v1.t
    ; (* Lifecycle *)
      mutable state : Seat_state.t
    ; (* Identity *)
      mutable name : string option
    ; (* State *)
      mutable output : Output.t option
    ; mutable position : Pointer_position.t
    ; mutable layer_focus : Layer_focus.t
    ; (* Keybindings *)
      mutable xkb_bindings : Xkb_binding.t list
    ; mutable pointer_bindings : Pointer_binding.t list
    ; mutable pending_actions : Action.t Queue.t
    ; (* Pointer state *)
      mutable hovered : Window.t option
    ; mutable interacted : Window.t option
    ; mutable focus_request : Focus_request.t
    ; mutable cursor_target : Window.t option
    ; (* Interactive op state *)
      mutable op : Seat_op.t
    }
end =
  Seat

and Window_manager : sig
  type t =
    { (* Wayland objects *)
      river_wm_v1 : [ `V4 ] Rwm.River_window_manager_v1.t
    ; river_xkb_v1 : [ `V2 ] Xkb.River_xkb_bindings_v1.t
    ; river_lsh_v1 : [ `V1 ] Rlsh.River_layer_shell_v1.t
    ; registry : Wayland.Registry.t
    ; (* Lifecycle *)
      shutdown : Eio.Condition.t
    ; mutable shutdown_origin : [ `Local | `Compositor ] option
    ; (* State *)
      mutable focused_output : Output.t option
    ; mutable dirty : bool
    ; (* Managed items *)
      mutable outputs : Output.t list (* Sorted by focus order *)
    ; mutable windows : Window.t list
    ; mutable seats : Seat.t list
    ; (* User configuration *)
      config : Config.t
    ; mutable config_loaded : bool
    ; (* Layout registry *)
      layout_registry : Layout_registry.t
    ; (* IPC state *)
      ipc : Ipc_state.t
    }
end =
  Window_manager
