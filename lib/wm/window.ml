(* ocdwm window - window handlers *)
open Ocdwm_core.Types
open Types

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

let destroy (w : window) =
  Rwm.River_window_v1.destroy w.obj;
  Wayland.Proxy.delete w.obj;
  Rwm.River_node_v1.destroy w.node

let set_position (w : window) ~(x : int32) ~(y : int32) =
  w.geom <- { x; y; w = w.geom.w; h = w.geom.h };
  Rwm.River_node_v1.set_position w.node ~x ~y

let river_sync_geom (w : window) (g : int32 rect) =
  Rwm.River_node_v1.set_position w.node ~x:g.x ~y:g.y;
  Rwm.River_window_v1.propose_dimensions w.obj ~width:g.w
    ~height:g.h

let set_geom (w : window) (g : int32 rect) =
  w.geom <- g;
  river_sync_geom w g

let is_visible (w : window) =
  match w.output with
  | Some o -> Int32.logand w.tags o.selected_tags <> 0l
  | None -> false

let is_tiled (w : window) = w.presentation = P_tiled

let remember_float (w : window) =
  w.float_geom <- Some w.geom

let tile (w : window) =
  if w.presentation = P_floating then remember_float w;
  w.presentation <- P_tiled

let clamp_dim ~min_v ~max_v v =
  v
  |> (if min_v > 0l then Int32.max min_v else Fun.id)
  |> if max_v > 0l then Int32.min max_v else Fun.id

let clamp (w : window) (g : int rect) =
  let h = w.size_hints in
  Int32.
    {
      x = of_int g.x;
      y = of_int g.y;
      w =
        of_int g.w
        |> clamp_dim ~min_v:h.min_w ~max_v:h.max_w;
      h =
        of_int g.h
        |> clamp_dim ~min_v:h.min_h ~max_v:h.max_h;
    }

let clamp32 (w : window) (g : int32 rect) =
  let h = w.size_hints in
  Int32.
    {
      x = g.x;
      y = g.y;
      w = clamp_dim ~min_v:h.min_w ~max_v:h.max_w g.w;
      h = clamp_dim ~min_v:h.min_h ~max_v:h.max_h g.h;
    }

let restore_or_seed_float (w : window) =
  match w.output with
  | None -> ()
  | Some o -> begin
      let g =
        match w.float_geom with
        | Some g -> g
        | None -> begin
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
          end
      in
      let g = clamp32 w g in
      w.float_geom <- Some g;
      set_geom w g
    end

let float (w : window) =
  w.presentation <- P_floating;
  restore_or_seed_float w

let toggle_floating = function
  | None -> ()
  | Some (w : window) ->
      begin if w.output <> None then
        match w.presentation with
        | P_tiled -> float w
        | P_floating when not w.is_fixed -> tile w
        | P_floating
        | P_fullscreen _ ->
            ()
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
      | `Tiled -> tile w
      | `Floating -> float w
    end
