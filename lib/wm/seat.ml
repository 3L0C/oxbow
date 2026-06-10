open! Ocdwm_core

type t = Types.Seat.t

let xkb_binding_destroy (_ : Ctx.manage Ctx.t) (binding : Types.Xkb_binding.t) =
  River.Xkb_bindings.River_xkb_binding_v1.destroy binding.obj
;;

let unbind_xkb_binding
      (ctx : Ctx.manage Ctx.t)
      (s : t)
      (mods : int32)
      (keysym : Xkbcommon.Keysym.t)
  =
  let matches (b : Types.Xkb_binding.t) = b.mods = mods && b.keysym = keysym in
  let to_destroy, to_keep = List.partition matches s.xkb_bindings in
  List.iter (xkb_binding_destroy ctx) to_destroy;
  s.xkb_bindings <- to_keep
;;

let xkb_binding_create
      (ctx : Ctx.manage Ctx.t)
      (s : t)
      (mods : int32)
      (keysym : Xkbcommon.Keysym.t)
      (action : Action.t)
  =
  let wm = Ctx.wm ctx in
  let body = Request_body.Trigger action in
  let keysym_i32 = Int32.of_int (Xkbcommon.Keysym.to_int keysym) in
  let binding : Types.Xkb_binding.t =
    { obj =
        River.Xkb_bindings.River_xkb_bindings_v1.get_xkb_binding
          wm.river_xkb_v1
          ~seat:s.obj
          object
            inherit [_] River.Xkb_bindings.River_xkb_binding_v1.v2
            method on_stop_repeat _ = ()
            method on_released _ = ()

            method on_pressed _ =
              Queue.push Pending_request.{ body; reply = None } s.pending_requests
          end
          ~keysym:keysym_i32
          ~modifiers:mods
    ; seat = s
    ; action
    ; mods
    ; keysym
    }
  in
  River.Xkb_bindings.River_xkb_binding_v1.enable binding.obj;
  s.xkb_bindings <- binding :: s.xkb_bindings
;;

let replace_xkb_binding
      (ctx : Ctx.manage Ctx.t)
      (s : t)
      (mods : int32)
      (keysym : Xkbcommon.Keysym.t)
      (action : Ocdwm_core.Action.t)
  =
  unbind_xkb_binding ctx s mods keysym;
  xkb_binding_create ctx s mods keysym action
;;

let pointer_binding_destroy (_ : Ctx.manage Ctx.t) (pointer : Types.Pointer_binding.t) =
  River.Window_management.River_pointer_binding_v1.destroy pointer.obj
;;

let unbind_pointer_binding
      (ctx : Ctx.manage Ctx.t)
      (s : t)
      (mods : int32)
      (button : Input_event.t)
  =
  let matches (p : Types.Pointer_binding.t) = p.mods = mods && p.button = button in
  let to_destroy, to_keep = List.partition matches s.pointer_bindings in
  List.iter (pointer_binding_destroy ctx) to_destroy;
  s.pointer_bindings <- to_keep
;;

let pointer_binding_create
      (_ : Ctx.manage Ctx.t)
      (s : t)
      (mods : int32)
      (button : Input_event.t)
      (action : Action.t)
  =
  let body = Request_body.Trigger action in
  let binding : Types.Pointer_binding.t =
    { obj =
        River.Window_management.River_seat_v1.get_pointer_binding
          s.obj
          object
            inherit [_] River.Window_management.River_pointer_binding_v1.v4
            method on_released _ = ()

            method on_pressed _ =
              Queue.push Pending_request.{ body; reply = None } s.pending_requests
          end
          ~button:(Input_event.to_int32 button)
          ~modifiers:mods
    ; seat = s
    ; action
    ; mods
    ; button
    }
  in
  River.Window_management.River_pointer_binding_v1.enable binding.obj;
  s.pointer_bindings <- binding :: s.pointer_bindings
;;

let replace_pointer_binding
      (ctx : Ctx.manage Ctx.t)
      (s : t)
      (mods : int32)
      (button : Input_event.t)
      (action : Ocdwm_core.Action.t)
  =
  unbind_pointer_binding ctx s mods button;
  pointer_binding_create ctx s mods button action
;;

let destroy (ctx : Ctx.manage Ctx.t) (s : t) =
  List.iter (xkb_binding_destroy ctx) s.xkb_bindings;
  List.iter (pointer_binding_destroy ctx) s.pointer_bindings;
  River.Layer_shell.River_layer_shell_seat_v1.destroy s.layer_shell;
  River.Window_management.River_seat_v1.destroy s.obj;
  Wayland.Proxy.delete s.obj
;;

let init (ctx : Ctx.manage Ctx.t) (s : t) =
  let wm = Ctx.wm ctx in
  let modkey = wm.config.modkey in
  let alt = River.Window_management.River_seat_v1.Modifiers.mod1 in
  let shift = River.Window_management.River_seat_v1.Modifiers.shift in
  let xkb_bindings =
    Xkbcommon.Keysym.
      [ (* mods, keysym,   action *)
        modkey, K_Return, Action.Spawn "kitty"
      ; modkey, K_q, Action.Close_focused
      ; modkey, K_j, Action.Focus_window_logical Next
      ; modkey, K_k, Action.Focus_window_logical Prev
      ; modkey, K_Escape, Action.Close_wm
      ; Int32.(logor modkey shift), K_Escape, Action.Exit_session
      ; modkey, K_h, Action.Tag_view_cycle Prev
      ; modkey, K_l, Action.Tag_view_cycle Next
      ; modkey, K_Tab, Action.Tag_view_cycle Next
      ; modkey, K_ISO_Left_Tab, Action.Tag_view_cycle Prev
      ; Int32.(logor modkey alt), K_Tab, Layout_cycle Next
      ; Int32.(logor modkey alt), K_ISO_Left_Tab, Layout_cycle Prev
      ; Int32.(logor modkey shift), K_space, Toggle_floating
      ; modkey, K_v, Toggle_fullscreen
      ; modkey, K_I, Toggle_fake_fullscreen
      ; modkey, K_F, Toggle_maximize
      ; modkey, K_H, Set_mfact Delta.(Rel (-0.05))
      ; modkey, K_L, Set_mfact Delta.(Rel 0.05)
      ; modkey, K_a, Set_mfact Delta.(Abs 0.55)
      ; modkey, K_space, Zoom
      ; modkey, K_J, Shift Next
      ; modkey, K_K, Shift Prev
      ]
  in
  let num_keys = Xkbcommon.Keysym.[ K_1; K_2; K_3; K_4; K_5; K_6; K_7; K_8; K_9 ] in
  let num_bindings =
    let open Tag_arg in
    List.mapi
      (fun i keysym ->
         modkey, keysym, Action.Tag_view (Tags_concrete (Tag_set.singleton (i + 1))))
      num_keys
  in
  let xkb_bindings = num_bindings @ xkb_bindings in
  let pointer_bindings =
    Input_event.
      [ (* mods, keysym,   action *)
        modkey, Btn_left, Action.Move_interactive
      ; modkey, Btn_right, Action.Resize_interactive
      ]
  in
  List.iter (fun (m, k, a) -> xkb_binding_create ctx s m k a) xkb_bindings;
  List.iter (fun (m, ec, a) -> pointer_binding_create ctx s m ec a) pointer_bindings;
  match wm.config.cursor_theme with
  | None -> ()
  | Some (name, size) -> Cursor_config.apply s ~name ~size
;;

let handle_pointer_position
      (wm : Types.Window_manager.t)
      (s : t)
      ~(x : int32)
      ~(y : int32)
  =
  s.position <- { x; y };
  if wm.config.focus_follows_pointer
  then (
    match Output.at_point ~x ~y wm.outputs with
    | None -> s.cursor_target <- None
    | Some o ->
      if not @@ Utils.opt_holds s.output o
      then Window_manager.request_focus_output wm s @@ Some o;
      (match s.hovered with
       | Some w when not @@ Utils.opt_holds s.cursor_target w ->
         s.focus_request <- Focus_window w;
         s.cursor_target <- s.hovered
       | _ -> ()))
;;

let mark_dirty (wm : Types.Window_manager.t) (s : t) =
  match s.state with
  | S_dirty _ -> ()
  | _ ->
    s.state <- S_dirty { prev = s.state };
    River.Window_management.River_window_manager_v1.manage_dirty wm.river_wm_v1
;;

let refresh_layer_focus (ctx : Ctx.manage Ctx.t) (s : t) =
  if s.layer_focus = Lf_none
  then (
    match Focus.focused_of s with
    | Some w -> Focus.focus_window ~force:true ctx s w
    | None -> Focus.clear ctx s)
;;

let refresh_cursor_target (s : t) =
  match s.hovered with
  | Some _ -> s.cursor_target <- s.hovered
  | _ -> ()
;;

let sync (ctx : Ctx.manage Ctx.t) (s : t) =
  (match s.state with
   | S_dirty { prev } ->
     refresh_layer_focus ctx s;
     s.state <- prev
   | _ -> ());
  refresh_cursor_target s
;;

let op_end (_ : Ctx.manage Ctx.t) (s : t) =
  match s.op with
  | Op_move _ | Op_resize _ ->
    s.op <- Op_none;
    River.Window_management.River_seat_v1.op_end s.obj
  | Op_none -> ()
;;
