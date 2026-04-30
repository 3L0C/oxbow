(* ocdwm seat - seat handlers *)
[@@@landmark "auto"]

module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

module Rlsh = Ocdwm_protocol.River_layer_shell_v1_client
module Xkb = Ocdwm_protocol.River_xkb_bindings_v1_client
module Utils = Ocdwm_core.Utils
open Ocdwm_core.Types
open Ocdwm_ipc.Types
open Types

let disconnect_seats (seats : seat list) (window : window) =
  List.iter
    (fun s ->
       begin match s.hovered with
       | Some w when w == window -> s.hovered <- None
       | _ -> ()
       end;
       begin match s.interacted with
       | Some w when w == window -> s.interacted <- None
       | _ -> ()
       end;
       begin match s.focus_request with
       | Focus_window w when w == window ->
           s.cursor_target <- None
       | _ -> ()
       end;
       begin match s.cursor_target with
       | Some w when w == window ->
           s.focus_request <- Focus_none
       | _ -> ()
       end;
       begin match s.op with
       | Op_move { window = w; _ }
       | Op_resize { window = w; _ }
         when w == window -> begin
           Rwm.River_seat_v1.op_end s.obj;
           s.op <- Op_none
         end
       | _ -> ()
       end)
    seats

let xkb_binding_destroy (binding : xkb_binding) =
  Xkb.River_xkb_binding_v1.destroy binding.obj

let xkb_binding_create
      (wm : window_manager)
      (s : seat)
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
          wm.river_xkb_v1 ~seat:s.obj
          object
            inherit [_] Xkb.River_xkb_binding_v1.v2
            method on_stop_repeat _ = ()
            method on_released _ = ()
            method on_pressed _ = s.pending_action <- action
          end
          ~keysym ~modifiers:mods;
      seat = s;
      action;
    }
  in
  Xkb.River_xkb_binding_v1.enable binding.obj;
  s.xkb_bindings <- binding :: s.xkb_bindings

let pointer_binding_destroy (pointer : pointer_binding) =
  Rwm.River_pointer_binding_v1.destroy pointer.obj

let pointer_binding_create
      (s : seat)
      (modifiers : int32)
      (ec : Input_event.code)
      (action : action)
  =
  let binding : pointer_binding =
    {
      obj =
        Rwm.River_seat_v1.get_pointer_binding s.obj
          object
            inherit [_] Rwm.River_pointer_binding_v1.v4
            method on_released _ = ()
            method on_pressed _ = s.pending_action <- action
          end
          ~button:(Input_event.to_int32 ec)
          ~modifiers;
      seat = s;
      action;
    }
  in
  Rwm.River_pointer_binding_v1.enable binding.obj;
  s.pointer_bindings <- binding :: s.pointer_bindings

let destroy (s : seat) =
  List.iter xkb_binding_destroy s.xkb_bindings;
  List.iter pointer_binding_destroy s.pointer_bindings;
  Rlsh.River_layer_shell_seat_v1.destroy s.layer_shell;
  Wayland.Proxy.delete s.layer_shell;
  Rwm.River_seat_v1.destroy s.obj;
  Wayland.Proxy.delete s.obj

let init (wm : window_manager) (s : seat) =
  let modkey = wm.config.modkey in
  let alt = Rwm.River_seat_v1.Modifiers.mod1 in
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
        (modkey, K_h, Tag_view_cycle Dir_prev);
        (modkey, K_l, Tag_view_cycle Dir_next);
        (modkey, K_Tab, Tag_view_cycle Dir_right);
        (modkey, K_ISO_Left_Tab, Tag_view_cycle Dir_left);
        ( Int32.(logor modkey alt),
          K_Tab,
          Layout_cycle Dir_next );
        ( Int32.(logor modkey alt),
          K_ISO_Left_Tab,
          Layout_cycle Dir_prev );
        ( Int32.(logor modkey shift),
          K_space,
          Toggle_floating );
        (modkey, K_v, Toggle_fullscreen);
        (modkey, K_I, Toggle_maximize);
      ]
  in
  let num_keys =
    Xkbcommon.Keysym.
      [ K_1; K_2; K_3; K_4; K_5; K_6; K_7; K_8; K_9 ]
  in
  let num_bindings =
    List.mapi
      (fun i keysym -> (modkey, keysym, Tag_view (i + 1)))
      num_keys
  in
  let xkb_bindings = num_bindings @ xkb_bindings in
  let pointer_bindings =
    Input_event.
      [
        (* mods, keysym,   action *)
        (modkey, Btn_left, Move_interactive);
        (modkey, Btn_right, Resize_interactive);
      ]
  in
  List.iter
    (fun (m, k, a) -> xkb_binding_create wm s m k a)
    xkb_bindings;
  List.iter
    (fun (m, ec, a) -> pointer_binding_create s m ec a)
    pointer_bindings

let pointer_move
      (wm : window_manager)
      (s : seat)
      (window : window)
  =
  Focus.focus_window wm s window;
  Rwm.River_seat_v1.op_start_pointer s.obj;
  s.op <-
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
      (s : seat)
      (window : window)
      (edges : int32)
  =
  Focus.focus_window wm s window;
  Rwm.River_window_v1.inform_resize_start window.obj;
  Rwm.River_seat_v1.op_start_pointer s.obj;
  s.op <-
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

let op (wm : window_manager) (s : seat) =
  match s.op with
  | Op_move op_m when op_m.release -> begin
      Rwm.River_seat_v1.op_end s.obj;
      let w = op_m.window in
      let cx = Int32.(div w.geom.w 2l |> add w.geom.x) in
      let cy = Int32.(div w.geom.h 2l |> add w.geom.y) in
      begin match
        Output.at_point ~x:cx ~y:cy wm.outputs
      with
      | Some o when not @@ Utils.opt_holds w.output o ->
      begin
          let prev = w.output in
          Output.move_window w o;
          Output.mark_dirty_opt prev;
          Output.mark_dirty o
        end
      | _ -> ()
      end;
      if op_m.window.presentation = P_floating then
        Window.remember_float op_m.window;
      s.op <- Op_none
    end
  | Op_resize op_r when op_r.release -> begin
      Rwm.River_window_v1.inform_resize_end op_r.window.obj;
      Rwm.River_seat_v1.op_end s.obj;
      if op_r.window.presentation = P_floating then
        Window.remember_float op_r.window;
      s.op <- Op_none
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

let handle_new (wm : window_manager) (s : seat) =
  match s.state with
  | S_new -> begin
      init wm s;
      s.state <- S_active
    end
  | _ -> ()

let handle_focus_request (wm : window_manager) (s : seat) =
  if
    wm.config.focus_follows_pointer
    && s.op = Op_none
    && s.layer_focus = Lf_none
  then
    begin match s.focus_request with
    | Focus_window w -> begin
        Focus.focus_window wm s w ~force:true;
        s.focus_request <- Focus_none
      end
    | Focus_clear -> begin
        Focus.clear s;
        s.focus_request <- Focus_none
      end
    | _ -> ()
    end

let handle_interaction (wm : window_manager) (seat : seat) =
  match seat.interacted with
  | None -> ()
  | Some w -> begin
      Focus.focus_window wm seat w;
      seat.interacted <- None
    end

let refresh_cursor_target (wm : window_manager) (s : seat) =
  s.cursor_target <-
    begin match s.output with
    | Some o ->
        Window.at_point ~x:s.position.x ~y:s.position.y
          o.focus_stack
    | None -> None
    end

let handle_pointer_position
      (wm : window_manager)
      (s : seat)
      ~(x : int32)
      ~(y : int32)
  =
  s.position <- { x; y };
  if wm.config.focus_follows_pointer then
    match Output.at_point ~x ~y wm.outputs with
    | None -> s.cursor_target <- None
    | Some o -> begin
        if not @@ Utils.opt_holds wm.focused_output o then begin
          wm.focused_output <- Some o;
          s.output <- Some o
        end;
        let new_target = Window.at_point ~x ~y o.windows in
        begin match new_target with
        | Some w
          when not @@ Utils.opt_holds s.cursor_target w ->
            s.focus_request <- Focus_window w
        | None when s.cursor_target <> None ->
            s.focus_request <- Focus_clear
        | _ -> ()
        end;
        s.cursor_target <- new_target
      end
