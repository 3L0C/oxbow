(* ocdwm seat - seat handlers *)
module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
module Xkb = Ocdwm_protocol.River_xkb_bindings_v1_client
open Types
open Ocdwm_ipc.Types

let disconnect_seats (seats : seat list) (window : window) =
  List.iter
    (fun seat ->
       begin match seat.op with
       | Op_move { window = w; _ }
       | Op_resize { window = w; _ }
         when w == window -> begin
           Rwm.River_seat_v1.op_end seat.obj;
           seat.op <- Op_none;
           seat.interacted <- None;
           seat.hovered <- None
         end
       | _ -> ()
       end)
    seats

let xkb_binding_destroy (binding : xkb_binding) =
  Xkb.River_xkb_binding_v1.destroy binding.obj

let xkb_binding_create
      (wm : window_manager)
      (seat : seat)
      (mods : int32)
      (keysym : Xkbcommon.Keysym.t)
      (action : action)
  =
  let keysym =
    Int32.of_int (Xkbcommon.Keysym.to_int keysym)
  in
  let binding : xkb_binding =
    {
      obj =
        Xkb.River_xkb_bindings_v1.get_xkb_binding
          wm.river_xkb_v1 ~seat:seat.obj
          object
            inherit [_] Xkb.River_xkb_binding_v1.v2
            method on_stop_repeat _ = ()
            method on_released _ = ()

            method on_pressed _ =
              seat.pending_action <- action
          end
          ~keysym ~modifiers:mods;
      seat;
      action;
    }
  in
  Xkb.River_xkb_binding_v1.enable binding.obj;
  seat.xkb_bindings <- binding :: seat.xkb_bindings

let pointer_binding_destroy (pointer : pointer_binding) =
  Rwm.River_pointer_binding_v1.destroy pointer.obj

let pointer_binding_create
      (seat : seat)
      (modifiers : int32)
      (ec : Input_event.code)
      (action : action)
  =
  let binding : pointer_binding =
    {
      obj =
        Rwm.River_seat_v1.get_pointer_binding seat.obj
          object
            inherit [_] Rwm.River_pointer_binding_v1.v4
            method on_released _ = ()

            method on_pressed _ =
              seat.pending_action <- action
          end
          ~button:(Input_event.to_int32 ec)
          ~modifiers;
      seat;
      action;
    }
  in
  Rwm.River_pointer_binding_v1.enable binding.obj;
  seat.pointer_bindings <- binding :: seat.pointer_bindings

let destroy seat =
  List.iter xkb_binding_destroy seat.xkb_bindings;
  List.iter pointer_binding_destroy seat.pointer_bindings;
  Rlsh.River_layer_shell_seat_v1.destroy seat.layer_shell;
  Wayland.Proxy.delete seat.layer_shell;
  Rwm.River_seat_v1.destroy seat.obj;
  Wayland.Proxy.delete seat.obj

let init (wm : window_manager) (seat : seat) =
  let modkey = wm.config.modkey in
  let shift = Rwm.River_seat_v1.Modifiers.shift in
  let xkb_bindings =
    Xkbcommon.Keysym.
      [
        (* mods, keysym,   action *)
        (modkey, K_Return, Spawn [| "kitty" |]);
        (modkey, K_q, Close_focused);
        (modkey, K_j, Focus_window Dir_next);
        (modkey, K_k, Focus_window Dir_prev);
        (modkey, K_Escape, Exit_wm);
        (modkey, K_Tab, Layout_cycle Dir_next);
        ( Int32.(logor modkey shift),
          K_space,
          Toggle_floating );
        (modkey, K_v, Toggle_fullscreen);
        (modkey, K_I, Toggle_maximize);
      ]
  in
  let pointer_bindings =
    Input_event.
      [
        (* mods, keysym,   action *)
        (modkey, Btn_left, Move_interactive);
        (modkey, Btn_right, Resize_interactive);
      ]
  in
  List.iter
    (fun (m, k, a) -> xkb_binding_create wm seat m k a)
    xkb_bindings;
  List.iter
    (fun (m, ec, a) -> pointer_binding_create seat m ec a)
    pointer_bindings

let pointer_move
      (wm : window_manager)
      (seat : seat)
      (window : window)
  =
  Focus.focus_window wm seat window;
  Rwm.River_seat_v1.op_start_pointer seat.obj;
  seat.op <-
    Op_move
      {
        window;
        start_x = window.geom.x;
        start_y = window.geom.y;
        dx = 0l;
        dy = 0l;
        release = false;
      }

let pointer_resize
      (wm : window_manager)
      (seat : seat)
      (window : window)
      (edges : int32)
  =
  Focus.focus_window wm seat window;
  Rwm.River_window_v1.inform_resize_start window.obj;
  Rwm.River_seat_v1.op_start_pointer seat.obj;
  seat.op <-
    Op_resize
      {
        window;
        edges;
        start_x = window.geom.x;
        start_y = window.geom.y;
        start_w = window.geom.w;
        start_h = window.geom.h;
        dx = 0l;
        dy = 0l;
        release = false;
      }

let spawn_kitty () =
  match Unix.fork () with
  | 0 -> Unix.execvp "kitty" [||]
  | pid -> ()

let op (wm : window_manager) (seat : seat) =
  match seat.op with
  | Op_move op_m when op_m.release -> begin
      Rwm.River_seat_v1.op_end seat.obj;
      if op_m.window.presentation = P_floating then
        Window.remember_float op_m.window;
      seat.op <- Op_none
    end
  | Op_resize op_r when op_r.release -> begin
      Rwm.River_window_v1.inform_resize_end op_r.window.obj;
      Rwm.River_seat_v1.op_end seat.obj;
      if op_r.window.presentation = P_floating then
        Window.remember_float op_r.window;
      seat.op <- Op_none
    end
  | Op_resize op_r -> begin
      let left =
        Int32.logand op_r.edges
          Rwm.River_window_v1.Edges.left
        <> 0l
      in
      let right =
        Int32.logand op_r.edges
          Rwm.River_window_v1.Edges.right
        <> 0l
      in
      let top =
        Int32.logand op_r.edges
          Rwm.River_window_v1.Edges.top
        <> 0l
      in
      let bottom =
        Int32.logand op_r.edges
          Rwm.River_window_v1.Edges.bottom
        <> 0l
      in
      let width =
        match (left, right) with
        | true, true
        | false, false ->
            op_r.start_w
        | true, false -> Int32.sub op_r.start_w op_r.dx
        | false, true -> Int32.add op_r.start_w op_r.dx
      in
      let height =
        match (top, bottom) with
        | true, true
        | false, false ->
            op_r.start_h
        | true, false -> Int32.sub op_r.start_h op_r.dy
        | false, true -> Int32.add op_r.start_h op_r.dy
      in
      Rwm.River_window_v1.propose_dimensions op_r.window.obj
        ~width:(max 1l width) ~height:(max 1l height)
    end
  (* Op_resize *)
  | Op_none
  | _ ->
      ()
