(** [close ctx window] asks [window] to close.

    {b Effects:} sends River request *)
val close : Ctx.manage Ctx.t -> Types.Window.t -> unit

(** [op_start_pointer ctx seat] starts a pointer operation on [seat].

    {b Effects:} sends River request *)
val op_start_pointer : Ctx.manage Ctx.t -> Types.Seat.t -> unit

(** [op_end ctx seat] ends the pointer operation on [seat].

    {b Effects:} sends River request *)
val op_end : Ctx.manage Ctx.t -> Types.Seat.t -> unit

(** [pointer_warp ctx seat ~x ~y] warps the pointer of [seat] to ([x], [y]).

    {b Effects:} sends River request *)
val pointer_warp : Ctx.manage Ctx.t -> Types.Seat.t -> x:int32 -> y:int32 -> unit

(** [manage_dirty wm] asks river for a manage sequence.

    {b Effects:} sends River request *)
val manage_dirty : Types.Wm.t -> unit

(** [exit_session wm] asks river to end the session.

    {b Effects:} sends River request *)
val exit_session : Types.Wm.t -> unit

(** [set_xcursor_theme seat ~name ~size] sets the cursor theme of [seat].

    {b Effects:} sends River request *)
val set_xcursor_theme : Types.Seat.t -> name:string -> size:int32 -> unit

(** [set_default output] makes [output] the default output of the layer shell.

    {b Effects:} sends River request *)
val set_default : Types.Output.t -> unit

(** [set_repeat_info device ~rate ~delay] sets the key repeat of [device].

    {b Effects:} sends River request *)
val set_repeat_info : Types.Input_device.Device.t -> rate:int32 -> delay:int32 -> unit

(** [place_top ctx window] raises the node of [window].

    {b Effects:} sends River request *)
val place_top : [< `Manage | `Render ] Ctx.t -> Types.Window.t -> unit

(** [create_node window_obj] makes the node of a window.

    {b Effects:} sends River request *)
val create_node : Types.Window.Obj_.t -> Types.Window.Node.t

(** [create_xkb_binding wm ~seat ~keysym ~mods ~on_pressed] makes a keyboard
    binding.

    {b Effects:} sends River request *)
val create_xkb_binding
  :  Types.Wm.t
  -> seat:Types.Seat.Obj_.t
  -> keysym:int32
  -> mods:int32
  -> on_pressed:(unit -> unit)
  -> Types.Seat.Xkb_binding.Obj_.t

(** [create_pointer_binding seat_obj ~button ~mods ~on_pressed] makes a pointer
    binding.

    {b Effects:} sends River request *)
val create_pointer_binding
  :  Types.Seat.Obj_.t
  -> button:int32
  -> mods:int32
  -> on_pressed:(unit -> unit)
  -> Types.Seat.Pointer_binding.Obj_.t

(** [destroy_window window] destroys the node and the window object of [window],
    then deletes the window proxy.

    {b Effects:} sends River request *)
val destroy_window : Types.Window.t -> unit

(** [destroy_output output] destroys the layer-shell object and the output
    object of [output].

    {b Effects:} sends River request *)
val destroy_output : Types.Output.t -> unit

(** [destroy_seat seat] destroys the layer-shell object and the seat object of
    [seat].

    {b Effects:} sends River request *)
val destroy_seat : Types.Seat.t -> unit

(** [destroy_xkb_binding binding] destroys [binding].

    {b Effects:} sends River request *)
val destroy_xkb_binding : Types.Seat.Xkb_binding.t -> unit

(** [destroy_pointer_binding binding] destroys [binding].

    {b Effects:} sends River request *)
val destroy_pointer_binding : Types.Seat.Pointer_binding.t -> unit

(** [destroy_xkb_keyboard xkb] destroys [xkb] and deletes the proxy.

    {b Effects:} sends River request *)
val destroy_xkb_keyboard : Types.Input_device.Xkb.t -> unit

(** [destroy_input_device device] destroys [device] and deletes the proxy.

    {b Effects:} sends River request *)
val destroy_input_device : Types.Input_device.Device.t -> unit
