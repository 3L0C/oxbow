let close (_ : Ctx.manage Ctx.t) (w : Types.Window.t) =
  River.Window_management.River_window_v1.close w.obj
;;

let op_start_pointer (_ : Ctx.manage Ctx.t) (s : Types.Seat.t) =
  River.Window_management.River_seat_v1.op_start_pointer s.obj
;;

let op_end (_ : Ctx.manage Ctx.t) (s : Types.Seat.t) =
  River.Window_management.River_seat_v1.op_end s.obj
;;

let pointer_warp (_ : Ctx.manage Ctx.t) (s : Types.Seat.t) ~x ~y =
  River.Window_management.River_seat_v1.pointer_warp s.obj ~x ~y
;;

let manage_dirty (wm : Types.Wm.t) =
  River.Window_management.River_window_manager_v1.manage_dirty wm.river_wm_v1
;;

let exit_session (wm : Types.Wm.t) =
  River.Window_management.River_window_manager_v1.exit_session wm.river_wm_v1
;;

let set_xcursor_theme (seat : Types.Seat.t) ~(name : string) ~(size : int32) =
  River.Window_management.River_seat_v1.set_xcursor_theme seat.obj ~name ~size
;;

let set_default (output : Types.Output.t) =
  River.Layer_shell.River_layer_shell_output_v1.set_default output.layer_shell
;;

let set_repeat_info
      (device : Types.Input_device.Device.t)
      ~(rate : int32)
      ~(delay : int32)
  =
  River.Input_management.River_input_device_v1.set_repeat_info device ~rate ~delay
;;

let place_top (_ : Ctx.([< manage | render ]) Ctx.t) (w : Types.Window.t) =
  River.Window_management.River_node_v1.place_top w.node
;;

let create_node (obj : Types.Window.Obj_.t) =
  River.Window_management.River_window_v1.get_node obj
  @@ object
       inherit [_] River.Window_management.River_node_v1.v4
     end
;;

let create_xkb_binding
      (wm : Types.Wm.t)
      ~(seat : Types.Seat.Obj_.t)
      ~(keysym : int32)
      ~(mods : int32)
      ~(on_pressed : unit -> unit)
  =
  River.Xkb_bindings.River_xkb_bindings_v1.get_xkb_binding
    wm.river_xkb_v1
    object
      inherit [_] River.Xkb_bindings.River_xkb_binding_v1.v2
      method on_stop_repeat _ = ()
      method on_released _ = ()
      method on_pressed _ = on_pressed ()
    end
    ~seat
    ~keysym
    ~modifiers:mods
;;

let create_pointer_binding
      (seat : Types.Seat.Obj_.t)
      ~(button : int32)
      ~(mods : int32)
      ~(on_pressed : unit -> unit)
  : Types.Seat.Pointer_binding.Obj_.t
  =
  River.Window_management.River_seat_v1.get_pointer_binding
    seat
    object
      inherit [_] River.Window_management.River_pointer_binding_v1.v4
      method on_released _ = ()
      method on_pressed _ = on_pressed ()
    end
    ~button
    ~modifiers:mods
;;

let destroy_window (window : Types.Window.t) =
  River.Window_management.River_window_v1.destroy window.obj;
  Wayland.Proxy.delete window.obj;
  River.Window_management.River_node_v1.destroy window.node
;;

let destroy_output (output : Types.Output.t) =
  River.Layer_shell.River_layer_shell_output_v1.destroy output.layer_shell;
  River.Window_management.River_output_v1.destroy output.obj;
  Wayland.Proxy.delete output.obj
;;

let destroy_xkb_binding (binding : Types.Seat.Xkb_binding.t) =
  River.Xkb_bindings.River_xkb_binding_v1.destroy binding.obj
;;

let destroy_pointer_binding (pointer : Types.Seat.Pointer_binding.t) =
  River.Window_management.River_pointer_binding_v1.destroy pointer.obj
;;

let destroy_seat (s : Types.Seat.t) =
  List.iter destroy_xkb_binding s.xkb_bindings;
  List.iter destroy_pointer_binding s.pointer_bindings;
  River.Layer_shell.River_layer_shell_seat_v1.destroy s.layer_shell;
  River.Window_management.River_seat_v1.destroy s.obj;
  Wayland.Proxy.delete s.obj
;;

let destroy_xkb_keyboard (xkb : Types.Input_device.Xkb.t) =
  River.Xkb_config.River_xkb_keyboard_v1.destroy xkb;
  Wayland.Proxy.delete xkb
;;

let destroy_input_device (device : Types.Input_device.Device.t) =
  River.Input_management.River_input_device_v1.destroy device;
  Wayland.Proxy.delete device
;;
