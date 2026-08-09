(** [manage_dirty wm] asks river for a manage sequence. *)
val manage_dirty : Wire.Obj.Window_management.t -> unit

(** [exit_session wm] asks river to end the session. *)
val exit_session : Wire.Obj.Window_management.t -> unit

(** [set_xcursor_theme seat ~name ~size] sets the cursor theme of [seat]. *)
val set_xcursor_theme
  :  Wire.Obj.Window_management.Seat.t
  -> name:string
  -> size:int32
  -> unit

(** [set_default output] makes [output] the default for layer surfaces. *)
val set_default : Wire.Obj.Layer_shell.Output.t -> unit

(** [set_repeat_info device ~rate ~delay] sets the key repeat of [device]. *)
val set_repeat_info
  :  Wire.Obj.Input.Management.Device.t
  -> rate:int32
  -> delay:int32
  -> unit

(** [get_node window] get [window]'s render list node. *)
val get_node : Wire.Obj.Window_management.Window.t -> Wire.Obj.Window_management.Node.t

(** [create_xkb_binding xkb ~seat ~keysym ~mods ~on_pressed] defines a new
    xkbcommon key binding. *)
val create_xkb_binding
  :  Wire.Obj.Xkb.Bindings.t
  -> seat:Wire.Obj.Window_management.Seat.t
  -> keysym:int32
  -> mods:int32
  -> on_pressed:(unit -> unit)
  -> Wire.Obj.Xkb.Bindings.Binding.t

(** [create_pointer_binding seat ~button ~mods ~on_pressed] defines a new
    pointer binding. *)
val create_pointer_binding
  :  Wire.Obj.Window_management.Seat.t
  -> button:int32
  -> mods:int32
  -> on_pressed:(unit -> unit)
  -> Wire.Obj.Window_management.Pointer_binding.t

(** [create_xkb_bindings_seat xkb ~seat ~on_modifiers_update] creates the xkb
    bindings seat object for [seat]. *)
val create_xkb_bindings_seat
  :  Wire.Obj.Xkb.Bindings.t
  -> seat:Wire.Obj.Window_management.Seat.t
  -> on_modifiers_update:(old:int32 -> new_:int32 -> unit)
  -> Wire.Obj.Xkb.Bindings.Seat.t

(** [destroy_window ~window ~node] destroys the [window] and [node] objects. *)
val destroy_window
  :  window:Wire.Obj.Window_management.Window.t
  -> node:Wire.Obj.Window_management.Node.t
  -> unit

(** [destroy_output ~output ~layer_shell] destroys the [output] and
    [layer_shell] objects. *)
val destroy_output
  :  output:Wire.Obj.Window_management.Output.t
  -> layer_shell:Wire.Obj.Layer_shell.Output.t
  -> unit

(** [destroy_xkb_binding binding] destroys the [binding] object. *)
val destroy_xkb_binding : Wire.Obj.Xkb.Bindings.Binding.t -> unit

(** [destroy_pointer_binding binding] destroys the [binding] object. *)
val destroy_pointer_binding : Wire.Obj.Window_management.Pointer_binding.t -> unit

(** [destroy_seat ~seat ~layer_shell ~xkb_seat] destroys the [seat],
    [layer_shell], and [xkb_seat] objects. *)
val destroy_seat
  :  seat:Wire.Obj.Window_management.Seat.t
  -> layer_shell:Wire.Obj.Layer_shell.Seat.t
  -> xkb_seat:Wire.Obj.Xkb.Bindings.Seat.t
  -> unit

(** [set_keymap keyboard ~keymap] sets the [keymap] for [keyboard]. *)
val set_keymap
  :  Wire.Obj.Xkb.Config.Keyboard.t
  -> keymap:Wire.Obj.Xkb.Config.Keymap.t
  -> unit

(** [destroy_xkb_keyboard keyboard] destroys the [keyboard] object. *)
val destroy_xkb_keyboard : Wire.Obj.Xkb.Config.Keyboard.t -> unit

(** [destroy_input_device device] destroys the [device] object. *)
val destroy_input_device : Wire.Obj.Input.Management.Device.t -> unit

(** [set_tap dev ~device enabled] sets tap-to-click. *)
val set_tap : Wire.Obj.Input.Config.Device.t -> device:string -> bool -> unit

(** [set_drag dev ~device enabled] sets tap-and-drag. *)
val set_drag : Wire.Obj.Input.Config.Device.t -> device:string -> bool -> unit

(** [set_drag_lock dev ~device state] sets the drag-lock mode. *)
val set_drag_lock
  :  Wire.Obj.Input.Config.Device.t
  -> device:string
  -> Wire.Libinput.Drag_lock_state.t
  -> unit

(** [set_three_finger_drag dev ~device state] sets the three-finger-drag mode. *)
val set_three_finger_drag
  :  Wire.Obj.Input.Config.Device.t
  -> device:string
  -> Wire.Libinput.Three_finger_drag_state.t
  -> unit

(** [set_dwt dev ~device enabled] sets disable-while-typing. *)
val set_dwt : Wire.Obj.Input.Config.Device.t -> device:string -> bool -> unit

(** [set_dwtp dev ~device enabled] sets disable-while-trackpointing. *)
val set_dwtp : Wire.Obj.Input.Config.Device.t -> device:string -> bool -> unit

(** [set_natural_scroll dev ~device enabled] sets natural scroll. *)
val set_natural_scroll : Wire.Obj.Input.Config.Device.t -> device:string -> bool -> unit

(** [set_left_handed dev ~device enabled] sets left-handed mode. *)
val set_left_handed : Wire.Obj.Input.Config.Device.t -> device:string -> bool -> unit

(** [set_middle_emulation dev ~device enabled] sets middle-button emulation. *)
val set_middle_emulation : Wire.Obj.Input.Config.Device.t -> device:string -> bool -> unit

(** [set_scroll_button_lock dev ~device enabled] sets scroll-button lock. *)
val set_scroll_button_lock
  :  Wire.Obj.Input.Config.Device.t
  -> device:string
  -> bool
  -> unit

(** [set_send_events dev ~device mode] sets the send-events mode. *)
val set_send_events
  :  Wire.Obj.Input.Config.Device.t
  -> device:string
  -> Wire.Libinput.Send_events_modes.t
  -> unit

(** [set_tap_button_map dev ~device map] sets the tap button order. *)
val set_tap_button_map
  :  Wire.Obj.Input.Config.Device.t
  -> device:string
  -> Wire.Libinput.Tap_button_map.t
  -> unit

(** [set_clickfinger_button_map dev ~device map] sets the clickfinger button
    order. *)
val set_clickfinger_button_map
  :  Wire.Obj.Input.Config.Device.t
  -> device:string
  -> Wire.Libinput.Clickfinger_button_map.t
  -> unit

(** [set_click_method dev ~device method_] sets the click method. *)
val set_click_method
  :  Wire.Obj.Input.Config.Device.t
  -> device:string
  -> Wire.Libinput.Click_method.t
  -> unit

(** [set_scroll_method dev ~device method_] sets the scroll method. *)
val set_scroll_method
  :  Wire.Obj.Input.Config.Device.t
  -> device:string
  -> Wire.Libinput.Scroll_method.t
  -> unit

(** [set_accel_profile dev ~device profile] sets the acceleration profile. *)
val set_accel_profile
  :  Wire.Obj.Input.Config.Device.t
  -> device:string
  -> Wire.Libinput.Accel_profile.t
  -> unit

(** [set_accel_speed dev ~device speed] sets the acceleration speed, in
    [-1, 1]. *)
val set_accel_speed : Wire.Obj.Input.Config.Device.t -> device:string -> float -> unit

(** [set_scroll_button dev ~device button] sets the on-button-down scroll
    button to the Linux input-event code [button]. *)
val set_scroll_button : Wire.Obj.Input.Config.Device.t -> device:string -> int32 -> unit

(** [set_scroll_factor device factor] scales the scroll speed of [device] by
    [factor]. [factor] must not be negative. *)
val set_scroll_factor : Wire.Obj.Input.Management.Device.t -> float -> unit

(** [destroy_libinput_device device] destroys the [device] object. *)
val destroy_libinput_device : Wire.Obj.Input.Config.Device.t -> unit
