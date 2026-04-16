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

let is_tiled (w : window) = w.presentation = P_tiled

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
      w.presentation <- P_floating;
      set_floating_geom w geom
    end

let tile (w : window) =
  if not w.is_fixed then w.presentation <- P_tiled

let toggle_floating = function
  | None -> ()
  | Some (w : window) ->
      begin if w.output <> None then
        match w.presentation with
        | P_tiled -> float w
        | P_floating -> tile w
        | P_fullscreen _ -> ()
      end

let is_fullscreen (w : window) =
  match w.presentation with
  | P_fullscreen _ -> true
  | _ -> false

let fullscreen (w : window) =
  match w.output with
  | None -> ()
  | Some o -> begin
      Rwm.River_window_v1.fullscreen w.obj ~output:o.obj;
      Rwm.River_window_v1.inform_fullscreen w.obj
    end

let exit_fullscreen
      (w : window)
      (p : [ `Tiled | `Floating ])
  =
  match w.output with
  | None -> ()
  | Some _ -> begin
      Rwm.River_window_v1.exit_fullscreen w.obj;
      Rwm.River_window_v1.inform_not_fullscreen w.obj;
      match p with
      | `Tiled -> w.presentation <- P_tiled
      | `Floating -> begin
          w.presentation <- P_floating;
          set_floating_geom w w.float_geom
        end
    end
