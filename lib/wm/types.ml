(* ocdwm types - shared type definitions *)

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
module Xkb = Ocdwm_protocol.River_xkb_bindings_v1_client
module Tag_set = Ocdwm_core.Tag_set
open Ocdwm_config.Types
open Ocdwm_core.Types
open Ocdwm_ipc.Types
open Ocdwm_layout.Types

exception Unavailable
exception Finished

type presentation =
  | P_tiled
  | P_floating
  | P_fullscreen of { restore : [ `Tiled | `Floating ] }

type 'a size_hints = {
  min_w : 'a;
  max_w : 'a;
  min_h : 'a;
  max_h : 'a;
}

type output_state =
  | O_active
  | O_dirty
  | O_removed

type output = {
  (* Wayland objects *)
  obj : [ `V4 ] Rwm.River_output_v1.t;
  layer_shell : [ `V1 ] Rlsh.River_layer_shell_output_v1.t;
  (* State *)
  mutable state : output_state;
  (* Identity *)
  mutable name : string option;
  (* Geometry *)
  mutable geom : int32 rect;
  (* Usable area *)
  mutable usable : int rect;
  (* Tag state *)
  mutable selected_tags : Tag_set.t;
  mutable previous_tags : Tag_set.t;
  (* Per-tag layout configuration *)
  tag_state : tag_data array;
  (* Focus stack - most recently focused first *)
  mutable focus_stack : window list;
  (* All windows on this output. Ordered in tiling order when filtered by
     selected_tags *)
  mutable windows : window list;
}
(* output *)

and output_box = { mutable body : output option }

and window_request =
  | Req_move of { seat : seat }
  | Req_resize of {
      seat : seat;
      edges : int32;
    }
  | Req_maximize
  | Req_unmaximize
  | Req_fullscreen of { output : output option }
  | Req_exit_fullscreen
  | Req_dimensions of {
      width : int32;
      height : int32;
    }

and window_state =
  | W_new
  | W_active
  | W_closing

and window_decoration =
  | W_only_csd
  | W_prefer_csd
  | W_prefer_ssd
  | W_no_preference

and window = {
  (* Wayland objects *)
  obj : [ `V4 ] Rwm.River_window_v1.t;
  node : [ `V4 ] Rwm.River_node_v1.t;
  (* Lifecycle *)
  mutable state : window_state;
  (* State *)
  id : int;
  mutable app_id : string option;
  mutable title : string option;
  mutable identifier : string option;
  mutable unreliable_pid : int32 option;
  mutable parent : window_box option;
  mutable decoration_hint : window_decoration option;
  mutable presentation_hint :
    Rwm.River_output_v1.Presentation_mode.t option;
  (* Geometry *)
  mutable geom : int32 rect;
  mutable float_geom : int32 rect option;
  (* Size hints from dimensions_hint *)
  mutable size_hints : int32 size_hints;
  (* Tag and output assignment *)
  mutable tags : Tag_set.t;
  mutable output : output option;
  (* State flags *)
  mutable is_fixed : bool;
  mutable is_urgent : bool;
  mutable is_maximized : bool;
  mutable is_hidden : bool;
  mutable presentation : presentation;
  (* Pointer op state *)
  mutable requests : window_request list;
}
(* window *)

and window_box = { mutable body : window option }

and xkb_binding = {
  obj : [ `V2 ] Xkb.River_xkb_binding_v1.t;
  seat : seat;
  mutable action : action;
}

and pointer_binding = {
  obj : [ `V4 ] Rwm.River_pointer_binding_v1.t;
  seat : seat;
  mutable action : action;
}

and pointer_position = {
  x : int32;
  y : int32;
}

and seat_op =
  | Op_none
  | Op_move of {
      window : window;
      start_x : int32;
      start_y : int32;
      mutable dx : int32;
      mutable dy : int32;
      mutable release : bool;
    }
  | Op_resize of {
      window : window;
      start_x : int32;
      start_y : int32;
      start_w : int32;
      start_h : int32;
      edges : int32;
      mutable dx : int32;
      mutable dy : int32;
      mutable release : bool;
    }

and seat_state =
  | S_new
  | S_active
  | S_closing

and layer_focus =
  | Lf_none
  | Lf_non_exclusive
  | Lf_exclusive

and focus_request =
  | Focus_none
  | Focus_window of window
  | Focus_clear

and seat = {
  (* Wayland objects *)
  obj : [ `V4 ] Rwm.River_seat_v1.t;
  layer_shell : [ `V1 ] Rlsh.River_layer_shell_seat_v1.t;
  (* Lifecycle *)
  mutable state : seat_state;
  (* State *)
  mutable output : output option;
  mutable position : pointer_position;
  mutable layer_focus : layer_focus;
  (* Keybindings *)
  mutable xkb_bindings : xkb_binding list;
  mutable pointer_bindings : pointer_binding list;
  mutable pending_action : action;
  (* Pointer state *)
  mutable hovered : window option;
  mutable interacted : window option;
  mutable focus_request : focus_request;
  mutable cursor_target : window option;
  (* Interactive op state *)
  mutable op : seat_op;
}
(* active_seat *)

and seat_box = { mutable body : seat option }

type phase =
  | P_manage
  | P_render
  | P_idle

and window_manager = {
  (* Wayland objects *)
  river_wm_v1 : [ `V4 ] Rwm.River_window_manager_v1.t;
  river_xkb_v1 : [ `V2 ] Xkb.River_xkb_bindings_v1.t;
  river_lsh_v1 : [ `V1 ] Rlsh.River_layer_shell_v1.t;
  registry : Wayland.Registry.t;
  (* State *)
  mutable focused_output : output option;
  mutable phase : phase;
  (* Managed items *)
  mutable outputs : output list; (* Sorted by focus order *)
  mutable windows : window list;
  mutable seats : seat list;
  (* User configuration *)
  config : config;
  mutable config_loaded : bool;
  (* Layout registry *)
  layout_registry : layout_registry;
  (* IPC state *)
  ipc : ipc_state;
}

and wm_box = { mutable body : window_manager option }

type any_box =
  | Output_box of output_box
  | Window_box of window_box
  | Wm_box of wm_box
  | Seat_box of seat_box

type (_, _) Wayland.S.user_data +=
  | Boxed_data of any_box
  | Output_data of output
  | Window_data of window
  | Seat_data of seat
