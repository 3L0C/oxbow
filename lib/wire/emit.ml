let manage_dirty river_wm_v1 =
  River.Window_management.River_window_manager_v1.manage_dirty river_wm_v1
;;

let exit_session river_wm_v1 =
  River.Window_management.River_window_manager_v1.exit_session river_wm_v1
;;

let set_xcursor_theme seat ~name ~size =
  River.Window_management.River_seat_v1.set_xcursor_theme seat ~name ~size
;;

let set_default output = River.Layer_shell.River_layer_shell_output_v1.set_default output

let set_repeat_info device ~rate ~delay =
  River.Input.Management.River_input_device_v1.set_repeat_info device ~rate ~delay
;;

let get_node window =
  River.Window_management.River_window_v1.get_node window
  @@ object
       inherit [_] River.Window_management.River_node_v1.v4
     end
;;

let create_xkb_binding river_xkb_v1 ~seat ~keysym ~mods ~on_pressed =
  River.Xkb.Bindings.River_xkb_bindings_v1.get_xkb_binding
    river_xkb_v1
    object
      inherit [_] River.Xkb.Bindings.River_xkb_binding_v1.v2
      method on_stop_repeat _ = ()
      method on_released _ = ()
      method on_pressed _ = on_pressed ()
    end
    ~seat
    ~keysym
    ~modifiers:mods
;;

let create_pointer_binding seat ~button ~mods ~on_pressed =
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

let destroy_window ~window ~node =
  River.Window_management.River_window_v1.destroy window;
  Wayland.Proxy.delete window;
  River.Window_management.River_node_v1.destroy node
;;

let destroy_output ~output ~layer_shell =
  River.Layer_shell.River_layer_shell_output_v1.destroy layer_shell;
  River.Window_management.River_output_v1.destroy output;
  Wayland.Proxy.delete output
;;

let destroy_xkb_binding binding = River.Xkb.Bindings.River_xkb_binding_v1.destroy binding

let destroy_pointer_binding pointer =
  River.Window_management.River_pointer_binding_v1.destroy pointer
;;

let destroy_seat ~seat ~layer_shell =
  River.Layer_shell.River_layer_shell_seat_v1.destroy layer_shell;
  River.Window_management.River_seat_v1.destroy seat;
  Wayland.Proxy.delete seat
;;

let set_keymap keyboard ~keymap =
  River.Xkb.Config.River_xkb_keyboard_v1.set_keymap keyboard ~keymap
;;

let destroy_xkb_keyboard keyboard =
  River.Xkb.Config.River_xkb_keyboard_v1.destroy keyboard;
  Wayland.Proxy.delete keyboard
;;

let destroy_input_device device =
  River.Input.Management.River_input_device_v1.destroy device;
  Wayland.Proxy.delete device
;;
