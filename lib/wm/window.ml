(* ocdwm window - window handlers *)
open Ocdwm_core.Types
open Types

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

let destroy (w : window) =
  Rwm.River_window_v1.destroy w.obj;
  Rwm.River_node_v1.destroy w.node

let set_floating_position
      (w : window)
      ~(x : int32)
      ~(y : int32)
  =
  w.float_geom <-
    { x; y; w = w.float_geom.w; h = w.float_geom.h };
  Rwm.River_node_v1.set_position w.node ~x ~y

let set_tile_position (w : window) ~(x : int32) ~(y : int32)
  =
  w.tile_geom <-
    { x; y; w = w.tile_geom.w; h = w.tile_geom.h };
  Rwm.River_node_v1.set_position w.node ~x ~y

let river_sync_geom (w : window) (g : int32 rect) =
  Rwm.River_node_v1.set_position w.node ~x:g.x ~y:g.y;
  Rwm.River_window_v1.propose_dimensions w.obj ~width:g.w
    ~height:g.h

let set_floating_geom (w : window) (g : int32 rect) =
  w.float_geom <- g;
  river_sync_geom w g

let set_tiled_geom (w : window) (g : int32 rect) =
  w.tile_geom <- g;
  river_sync_geom w g

let is_visible (w : window) =
  match w.output with
  | Some o -> Int32.logand w.tags o.selected_tags <> 0l
  | None -> false

let is_tiled (w : window) = w.presentation = Tiled

let float (w : window) =
  match w.output with
  | None -> ()
  | Some o -> begin
      let geom =
        match w.float_geom with
        | { x = 0l; y = 0l; w = 0l; h = 0l } ->
            let usable =
              Int32.
                {
                  x = of_int o.usable.x;
                  y = of_int o.usable.y;
                  w = of_int o.usable.w;
                  h = of_int o.usable.h;
                }
            in
            Int32.
              {
                x = div usable.w 4l |> add usable.x;
                y = div usable.h 4l |> add usable.y;
                w = div usable.w 2l;
                h = div usable.h 2l;
              }
        | _ -> w.float_geom
      in
      w.presentation <- Floating;
      set_floating_geom w geom
    end

let tile (w : window) = w.presentation <- Tiled

let toggle_floating = function
  | None -> ()
  | Some (w : window) ->
      begin if w.output <> None then
        match w.presentation with
        | Tiled -> float w
        | Floating -> tile w
        | Fullscreen _ -> ()
      end
