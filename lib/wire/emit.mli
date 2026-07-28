(** [manage_dirty wm] asks river for a manage sequence.

    {b Effects:} sends River request *)
val manage_dirty : Wire.Obj.Window_management.Wm.t -> unit

(** [exit_session wm] asks river to end the session.

    {b Effects:} sends River request *)
val exit_session : Wire.Obj.Window_management.Wm.t -> unit

(** [set_xcursor_theme seat ~name ~size] sets the cursor theme of [seat].

    {b Effects:} sends River request *)
val set_xcursor_theme
  :  Wire.Obj.Window_management.Seat.t
  -> name:string
  -> size:int32
  -> unit

(** [set_default output] makes [output] the default for layer surfaces.

    {b Effects:} sends River request *)
val set_default : Wire.Obj.Layer_shell.Output.t -> unit

(** [set_repeat_info device ~rate ~delay] sets the key repeat of [device].

    {b Effects:} sends River request *)
val set_repeat_info
  :  Wire.Obj.Input.Management.Device.t
  -> rate:int32
  -> delay:int32
  -> unit

(** [get_node window] get [window]'s render list node.

    {b Effects:} sends River request *)
val get_node : Wire.Obj.Window_management.Window.t -> Wire.Obj.Window_management.Node.t

(** [create_xkb_binding xkb ~seat ~keysym ~mods ~on_pressed] defines a new
    xkbcommon key binding.

    {b Effects:} sends River request *)
val create_xkb_binding
  :  Wire.Obj.Xkb.Bindings.t
  -> seat:Wire.Obj.Window_management.Seat.t
  -> keysym:int32
  -> mods:int32
  -> on_pressed:(unit -> unit)
  -> Wire.Obj.Xkb.Bindings.Binding.t

(** [create_pointer_binding seat ~button ~mods ~on_pressed] defines a new
    pointer binding.

    {b Effects:} sends River request *)
val create_pointer_binding
  :  Wire.Obj.Window_management.Seat.t
  -> button:int32
  -> mods:int32
  -> on_pressed:(unit -> unit)
  -> Wire.Obj.Window_management.Pointer_binding.t

(** [destroy_window ~window ~node] destroys the [window] and [node] objects.

    {b Effects:} sends River request *)
val destroy_window
  :  window:Wire.Obj.Window_management.Window.t
  -> node:Wire.Obj.Window_management.Node.t
  -> unit

(** [destroy_output ~output ~layer_shell] destroys the [output] and
    [layer_shell] objects.

    {b Effects:} sends River request *)
val destroy_output
  :  output:Wire.Obj.Window_management.Output.t
  -> layer_shell:Wire.Obj.Layer_shell.Output.t
  -> unit

(** [destroy_xkb_binding binding] destroys the [binding] object.

    {b Effects:} sends River request *)
val destroy_xkb_binding : Wire.Obj.Xkb.Bindings.Binding.t -> unit

(** [destroy_pointer_binding binding] destroys the [binding] object.

    {b Effects:} sends River request *)
val destroy_pointer_binding : Wire.Obj.Window_management.Pointer_binding.t -> unit

(** [destroy_seat ~seat ~layer_shell] destroys the [seat] and [layer_shell]
    objects.

    {b Effects:} sends River request *)
val destroy_seat
  :  seat:Wire.Obj.Window_management.Seat.t
  -> layer_shell:Wire.Obj.Layer_shell.Seat.t
  -> unit

(** [set_keymap keyboard ~keymap] sets the [keymap] for [keyboard].

    {b Effects:} sends River request *)
val set_keymap
  :  Wire.Obj.Xkb.Config.Keyboard.t
  -> keymap:Wire.Obj.Xkb.Config.Keymap.t
  -> unit

(** [destroy_xkb_keyboard keyboard] destroys the [keyboard] object.

    {b Effects:} sends River request *)
val destroy_xkb_keyboard : Wire.Obj.Xkb.Config.Keyboard.t -> unit

(** [destroy_input_device device] destroys the [device] object.

    {b Effects:} sends River request *)
val destroy_input_device : Wire.Obj.Input.Management.Device.t -> unit
