(* ocdwm window - window handlers *)
open Types

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

let destroy (window : window) =
  Rwm.River_window_v1.destroy window.obj;
  Rwm.River_node_v1.destroy window.node

let set_position window ~(x : int32) ~(y : int32) =
  Rwm.River_node_v1.set_position window.node ~x ~y;
  window.x <- x;
  window.y <- y

let manage (wm : window_manager) (window : window) =
  if window.is_new then begin
    window.is_new <- false;
    set_position window ~x:0l ~y:0l;
    Rwm.River_window_v1.propose_dimensions window.obj
      ~width:0l ~height:0l
  end;
  (match window.pointer_move_requested with
  | None -> ()
  | Some seat ->
      wm.seat_handler.pointer_move wm seat window;
      window.pointer_move_requested <- None);
  match window.pointer_resize_requested with
  | None -> ()
  | Some seat ->
      wm.seat_handler.pointer_resize wm seat window
        window.pointer_resize_requested_edges;
      window.pointer_resize_requested <- None
