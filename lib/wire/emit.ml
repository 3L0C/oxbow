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
       inherit [_] River.Obj.Window_management.Client.node
     end
;;

let create_xkb_binding river_xkb_v1 ~seat ~keysym ~mods ~on_pressed =
  River.Xkb.Bindings.River_xkb_bindings_v1.get_xkb_binding
    river_xkb_v1
    object
      inherit [_] River.Obj.Xkb.Bindings.Client.binding
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
      inherit [_] River.Obj.Window_management.Client.pointer_binding
      method on_released _ = ()
      method on_pressed _ = on_pressed ()
    end
    ~button
    ~modifiers:mods
;;

let create_xkb_bindings_seat xkb ~seat ~on_modifiers_update =
  River.Xkb.Bindings.River_xkb_bindings_v1.get_seat
    xkb
    object
      inherit [_] River.Obj.Xkb.Bindings.Client.seat
      method on_modifiers_update _ ~old ~new_ = on_modifiers_update ~old ~new_
      method on_ate_unbound_key _ = ()
    end
    ~seat
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

let destroy_seat ~seat ~layer_shell ~xkb_seat =
  River.Layer_shell.River_layer_shell_seat_v1.destroy layer_shell;
  River.Xkb.Bindings.River_xkb_bindings_seat_v1.destroy xkb_seat;
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

let libinput_result ~device ~setting =
  Wayland.Proxy.Handler.cast_version
    object
      inherit [_] River.Obj.Input.Config.Client.result
      method on_success = ()

      method on_unsupported =
        Logs.warn @@ fun m -> m "%s: libinput %s unsupported" device setting

      method on_invalid = Logs.err @@ fun m -> m "%s: libinput %s invalid" device setting
    end
;;

module Libinput_device = River.Input.Config.River_libinput_device_v1

let set_tap dev ~device enabled =
  let state : Wire.Libinput.Tap_state.t = if enabled then Enabled else Disabled in
  ignore @@ Libinput_device.set_tap dev (libinput_result ~device ~setting:"tap") ~state
;;

let set_drag dev ~device enabled =
  let state : Wire.Libinput.Drag_state.t = if enabled then Enabled else Disabled in
  ignore @@ Libinput_device.set_drag dev (libinput_result ~device ~setting:"drag") ~state
;;

let set_drag_lock dev ~device state =
  ignore
  @@ Libinput_device.set_drag_lock
       dev
       (libinput_result ~device ~setting:"drag-lock")
       ~state
;;

let set_three_finger_drag dev ~device state =
  ignore
  @@ Libinput_device.set_three_finger_drag
       dev
       (libinput_result ~device ~setting:"three-finger-drag")
       ~state
;;

let set_dwt dev ~device enabled =
  let state : Wire.Libinput.Dwt_state.t = if enabled then Enabled else Disabled in
  ignore @@ Libinput_device.set_dwt dev (libinput_result ~device ~setting:"dwt") ~state
;;

let set_dwtp dev ~device enabled =
  let state : Wire.Libinput.Dwtp_state.t = if enabled then Enabled else Disabled in
  ignore @@ Libinput_device.set_dwtp dev (libinput_result ~device ~setting:"dwtp") ~state
;;

let set_natural_scroll dev ~device enabled =
  let state : Wire.Libinput.Natural_scroll_state.t =
    if enabled then Enabled else Disabled
  in
  ignore
  @@ Libinput_device.set_natural_scroll
       dev
       (libinput_result ~device ~setting:"natural-scroll")
       ~state
;;

let set_left_handed dev ~device enabled =
  let state : Wire.Libinput.Left_handed_state.t = if enabled then Enabled else Disabled in
  ignore
  @@ Libinput_device.set_left_handed
       dev
       (libinput_result ~device ~setting:"left-handed")
       ~state
;;

let set_middle_emulation dev ~device enabled =
  let state : Wire.Libinput.Middle_emulation_state.t =
    if enabled then Enabled else Disabled
  in
  ignore
  @@ Libinput_device.set_middle_emulation
       dev
       (libinput_result ~device ~setting:"middle-emulation")
       ~state
;;

let set_scroll_button_lock dev ~device enabled =
  let state : Wire.Libinput.Scroll_button_lock_state.t =
    if enabled then Enabled else Disabled
  in
  ignore
  @@ Libinput_device.set_scroll_button_lock
       dev
       (libinput_result ~device ~setting:"scroll-button-lock")
       ~state
;;

let set_send_events dev ~device mode =
  ignore
  @@ Libinput_device.set_send_events
       dev
       (libinput_result ~device ~setting:"send-events")
       ~mode
;;

let set_tap_button_map dev ~device button_map =
  ignore
  @@ Libinput_device.set_tap_button_map
       dev
       (libinput_result ~device ~setting:"tap-button-map")
       ~button_map
;;

let set_clickfinger_button_map dev ~device button_map =
  ignore
  @@ Libinput_device.set_clickfinger_button_map
       dev
       (libinput_result ~device ~setting:"clickfinger-button-map")
       ~button_map
;;

let set_click_method dev ~device method_ =
  ignore
  @@ Libinput_device.set_click_method
       dev
       (libinput_result ~device ~setting:"click-method")
       ~method_
;;

let set_scroll_method dev ~device method_ =
  ignore
  @@ Libinput_device.set_scroll_method
       dev
       (libinput_result ~device ~setting:"scroll-method")
       ~method_
;;

let set_accel_profile dev ~device profile =
  ignore
  @@ Libinput_device.set_accel_profile
       dev
       (libinput_result ~device ~setting:"accel-profile")
       ~profile
;;

let set_accel_speed dev ~device speed =
  let speed =
    let b = Bytes.create 8 in
    Bytes.set_int64_ne b 0 (Int64.bits_of_float speed);
    Bytes.to_string b
  in
  ignore
  @@ Libinput_device.set_accel_speed
       dev
       (libinput_result ~device ~setting:"accel-speed")
       ~speed
;;

let set_scroll_button dev ~device button =
  ignore
  @@ Libinput_device.set_scroll_button
       dev
       (libinput_result ~device ~setting:"scroll-button")
       ~button
;;

let set_scroll_factor device factor =
  let factor = Wayland.Fixed.of_bits (Int32.of_float (Float.round (factor *. 256.))) in
  River.Input.Management.River_input_device_v1.set_scroll_factor device ~factor
;;

let destroy_libinput_device device =
  Libinput_device.destroy device;
  Wayland.Proxy.delete device
;;
