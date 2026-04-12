(* ocdwm window - window handlers *)
open Ocdwm_core.Types
open Types

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

let destroy (window : window) =
  Rwm.River_window_v1.destroy window.obj;
  Rwm.River_node_v1.destroy window.node

let set_position (window : window) ~(x : int32) ~(y : int32)
  =
  window.old_geom <- window.geom;
  window.geom <-
    { x; y; w = window.geom.w; h = window.geom.h };
  Rwm.River_node_v1.set_position window.node ~x ~y

let set_geom (window : window) (g : int32 rect) =
  window.old_geom <- window.geom;
  window.geom <- g;
  Rwm.River_node_v1.set_position window.node ~x:g.x ~y:g.y;
  Rwm.River_window_v1.propose_dimensions window.obj
    ~width:g.w ~height:g.h

let is_visible (w : window) =
  match w.output with
  | Some o -> Int32.logand w.tags o.selected_tags <> 0l
  | None -> false
