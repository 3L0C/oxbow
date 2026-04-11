(* ocdwm window - window handlers *)
open Types

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

let destroy (window : window) =
  Rwm.River_window_v1.destroy window.obj;
  Rwm.River_node_v1.destroy window.node

let set_position (window : window) ~(x : int32) ~(y : int32)
  =
  Rwm.River_node_v1.set_position window.node ~x ~y;
  window.geom <-
    { x; y; w = window.geom.w; h = window.geom.h }

let is_visible (w : window) =
  match w.output with
  | Some o -> Int32.logand w.tags o.selected_tags <> 0l
  | None -> false
