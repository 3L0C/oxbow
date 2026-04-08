(* ocdwm types - shared type definitions *)

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

module Xkb = Ocdwm_protocol.River_xkb_bindings_v1_client

module Input_event = struct
  type code =
    | Key_unknown
    | Btn_left
    | Btn_right

  let of_int32 = function
    | 0x110l -> Btn_left
    | 0x111l -> Btn_right
    | _ -> Key_unknown

  let to_int32 = function
    | Btn_left -> 0x110l
    | Btn_right -> 0x111l
    | Key_unknown -> 240l
end

type action =
  | No_action
  | Spawn_foot
  | Close
  | Focus_next
  | Move
  | Resize
  | Exit

type seat_op =
  | Op_none
  | Op_move
  | Op_resize

type output = {
  mutable obj : [ `V4 ] Rwm.River_output_v1.t;
  mutable removed : bool;
}

and window = {
  mutable obj : [ `V4 ] Rwm.River_window_v1.t;
  node : [ `V4 ] Rwm.River_node_v1.t;
  mutable is_new : bool;
  mutable closed : bool;
  mutable x : int32;
  mutable y : int32;
  mutable width : int32;
  mutable height : int32;
  mutable pointer_move_requested : seat option;
  mutable pointer_resize_requested : seat option;
  mutable pointer_resize_requested_edges : int32;
}

and xkb_binding = {
  mutable obj : [ `V2 ] Xkb.River_xkb_binding_v1.t;
  mutable seat : seat;
  mutable action : action;
}

and pointer_binding = {
  mutable obj : [ `V4 ] Rwm.River_pointer_binding_v1.t;
  mutable seat : seat;
  mutable action : action;
}

and seat = {
  mutable obj : [ `V4 ] Rwm.River_seat_v1.t;
  mutable is_new : bool;
  mutable removed : bool;
  mutable focused : window option;
  mutable hovered : window option;
  mutable interacted : window option;
  mutable xkb_bindings : xkb_binding list;
  mutable pointer_bindings : pointer_binding list;
  mutable pending_action : action;
  mutable op : seat_op;
  mutable op_window : window option;
  mutable op_start_x : int32;
  mutable op_start_y : int32;
  mutable op_dx : int32;
  mutable op_dy : int32;
  mutable op_release : bool;
  mutable op_start_width : int32;
  mutable op_start_height : int32;
  mutable op_edges : int32;
}

and seat_handler = {
  pointer_move : window_manager -> seat -> window -> unit;
  pointer_resize :
    window_manager -> seat -> window -> int32 -> unit;
}

and window_handler = {
  set_position : window -> x:int32 -> y:int32 -> unit;
}

and window_manager = {
  mutable wm_v1 :
    [ `V4 ] Rwm.River_window_manager_v1.t option;
  mutable xkb_v1 :
    [ `V2 ] Xkb.River_xkb_bindings_v1.t option;
  mutable windows : window list;
  mutable outputs : output list;
  mutable seats : seat list;
  seat_handler : seat_handler;
  window_handler : window_handler;
}

type (_, _) Wayland.S.user_data +=
  | Output_data of output
  | Window_data of window
  | Seat_data of seat
