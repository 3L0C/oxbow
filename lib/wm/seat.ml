(* ocdwm seat - seat handlers *)
module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

module Xkb = Ocdwm_protocol.River_xkb_bindings_v1_client
open Types

let disconnect_seats seats window =
  List.iter
    (fun seat ->
       (match seat.focused with
       | Some w when w == window -> seat.focused <- None
       | _ -> ());
       match seat.op_window with
       | Some w when w == window ->
           Rwm.River_seat_v1.op_end seat.obj;
           seat.op <- Op_none;
           seat.op_window <- None
       | _ -> ())
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
  let xkb_v1 = Option.get wm.xkb_v1 in
  let keysym =
    Int32.of_int (Xkbcommon.Keysym.to_int keysym)
  in
  let binding : xkb_binding =
    {
      obj =
        Xkb.River_xkb_bindings_v1.get_xkb_binding xkb_v1
          ~seat:seat.obj
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
      (button : Input_event.code)
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
          ~button:(Input_event.to_int32 button)
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
  Rwm.River_seat_v1.destroy seat.obj

let init (wm : window_manager) (seat : seat) =
  let super = Rwm.River_seat_v1.Modifiers.mod4 in
  seat.is_new <- false;
  xkb_binding_create wm seat super Xkbcommon.Keysym.K_space
    Spawn_foot;
  xkb_binding_create wm seat super Xkbcommon.Keysym.K_q
    Close;
  xkb_binding_create wm seat super Xkbcommon.Keysym.K_n
    Focus_next;
  xkb_binding_create wm seat super Xkbcommon.Keysym.K_Escape
    Exit;
  pointer_binding_create seat super Input_event.Btn_left
    Move;
  pointer_binding_create seat super Input_event.Btn_right
    Resize

let focus
      (wm : window_manager)
      (seat : seat)
      (window : window option)
  =
  let get_top =
    match wm.windows with
    | w :: _ -> Some w
    | [] -> None
  in
  let window =
    match window with
    | Some _ -> window
    | None -> get_top
  in
  (match (seat.focused, window) with
  | Some w1, Some w2 when w1 == w2 -> ()
  | _, Some window -> begin
      Rwm.River_seat_v1.focus_window seat.obj
        ~window:window.obj;
      Rwm.River_node_v1.place_top window.node;
      wm.windows <-
        window
        :: List.filter (fun w -> w != window) wm.windows
    end
  | _, _ -> Rwm.River_seat_v1.clear_focus seat.obj);
  seat.focused <- window

let pointer_move
      (wm : window_manager)
      (seat : seat)
      (window : window)
  =
  focus wm seat (Some window);
  Rwm.River_seat_v1.op_start_pointer seat.obj;
  seat.op <- Op_move;
  seat.op_window <- Some window;
  seat.op_start_x <- window.x;
  seat.op_start_y <- window.y;
  seat.op_dx <- 0l;
  seat.op_dy <- 0l

let pointer_resize
      (wm : window_manager)
      (seat : seat)
      (window : window)
      (edges : int32)
  =
  focus wm seat (Some window);
  Rwm.River_window_v1.inform_resize_start window.obj;
  Rwm.River_seat_v1.op_start_pointer seat.obj;
  seat.op <- Op_resize;
  seat.op_window <- Some window;
  seat.op_edges <- edges;
  seat.op_start_x <- window.x;
  seat.op_start_y <- window.y;
  seat.op_start_width <- window.width;
  seat.op_start_height <- window.height;
  seat.op_dx <- 0l;
  seat.op_dy <- 0l

let spawn_foot () =
  match Unix.fork () with
  | 0 -> Unix.execvp "kitty" [||]
  | pid -> ()

let action (wm : window_manager) (seat : seat) = function
  | No_action -> ()
  | Spawn_foot -> spawn_foot ()
  | Close -> (
      match seat.focused with
      | Some window -> Rwm.River_window_v1.close window.obj
      | None -> ())
  | Focus_next -> (
      match List.length wm.windows with
      | 0 -> focus wm seat None
      | n -> focus wm seat (List.nth_opt wm.windows (n - 1))
      )
  | Move -> (
      match (seat.op, seat.hovered) with
      | Op_none, Some window -> pointer_move wm seat window
      | _, _ -> ())
  | Resize -> (
      match (seat.op, seat.hovered) with
      | Op_none, Some window ->
          pointer_resize wm seat window
            (Int32.logor Rwm.River_window_v1.Edges.right
               Rwm.River_window_v1.Edges.bottom)
      | _, _ -> ())
  | Exit ->
      Option.get wm.wm_v1
      |> Rwm.River_window_manager_v1.exit_session

let op (wm : window_manager) (seat : seat) =
  match seat.op with
  | Op_move when seat.op_release -> begin
      Rwm.River_seat_v1.op_end seat.obj;
      seat.op <- Op_none;
      seat.op_window <- None
    end
  | Op_resize when seat.op_release -> begin
      (Option.get seat.op_window).obj
      |> Rwm.River_window_v1.inform_resize_end;
      Rwm.River_seat_v1.op_end seat.obj;
      seat.op <- Op_none;
      seat.op_window <- None
    end
  | Op_resize -> begin
      let left =
        Int32.logand seat.op_edges
          Rwm.River_window_v1.Edges.left
        <> 0l
      in
      let right =
        Int32.logand seat.op_edges
          Rwm.River_window_v1.Edges.right
        <> 0l
      in
      let top =
        Int32.logand seat.op_edges
          Rwm.River_window_v1.Edges.top
        <> 0l
      in
      let bottom =
        Int32.logand seat.op_edges
          Rwm.River_window_v1.Edges.bottom
        <> 0l
      in
      let width =
        match (left, right) with
        | true, true
        | false, false ->
            seat.op_start_width
        | true, false ->
            Int32.sub seat.op_start_width seat.op_dx
        | false, true ->
            Int32.add seat.op_start_width seat.op_dx
      in
      let height =
        match (top, bottom) with
        | true, true
        | false, false ->
            seat.op_start_height
        | true, false ->
            Int32.sub seat.op_start_height seat.op_dy
        | false, true ->
            Int32.add seat.op_start_height seat.op_dy
      in
      Rwm.River_window_v1.propose_dimensions
        (Option.get seat.op_window).obj
        ~width:(max 1l width) ~height:(max 1l height)
    end
  (* Op_resize *)
  | Op_none
  | _ ->
      ()

let manage (wm : window_manager) (seat : seat) =
  if seat.is_new then init wm seat;
  focus wm seat seat.interacted;
  seat.interacted <- None;
  action wm seat seat.pending_action;
  seat.pending_action <- No_action;
  op wm seat;
  seat.op_release <- false

let render (wm : window_manager) (seat : seat) =
  begin match seat.op with
  | Op_none -> ()
  | Op_move ->
      wm.window_handler.set_position
        (Option.get seat.op_window)
        ~x:(Int32.add seat.op_start_x seat.op_dx)
        ~y:(Int32.add seat.op_start_y seat.op_dy)
  | Op_resize ->
      let x =
        if
          Int32.logand seat.op_edges
            Rwm.River_window_v1.Edges.left
          <> 0l
        then
          Int32.sub seat.op_start_width
            (Option.get seat.op_window).width
          |> Int32.add seat.op_start_x
        else seat.op_start_x
      in
      let y =
        if
          Int32.logand seat.op_edges
            Rwm.River_window_v1.Edges.top
          <> 0l
        then
          Int32.sub seat.op_start_height
            (Option.get seat.op_window).height
          |> Int32.add seat.op_start_y
        else seat.op_start_y
      in
      wm.window_handler.set_position
        (Option.get seat.op_window)
        ~x ~y
  end
