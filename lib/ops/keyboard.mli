(** [set_device_repeat_info device ~rate ~delay] sends River request to set the
    repeat info to [rate] and [delay] for [device]. Is a no-op when [device] is
    not a keyboard.

    {b Effects:} sends River request *)
val set_device_repeat_info
  :  Ocdwm_state.River.V.Input_management.t
       Ocdwm_state.River.Input_management.River_input_device_v1.t
  -> rate:int32
  -> delay:int32
  -> unit

(** [set_repeat_info wm ~rate ~delay] stores [rate]/[delay] in [wm]'s config and
    calls [set_device_repeat_info] on every entry registered keyboard input
    device.

    {b Effects:} mutates WM state; sends River request *)
val set_repeat_info : Ocdwm_state.Wm.t -> rate:int -> delay:int -> unit

(** [set_layout_file wm ~path] opens [path] and asks the compositor to compile
    it into a keymap, applied to every xkb keyboard once the [success] event
    arrives. Is [Error msg] on synchronous failure, [Ok None] otherwise.

    {b Effects:} mutates WM state; sends River request *)
val set_layout_file
  :  Ocdwm_state.Wm.t
  -> path:string
  -> (Yojson.Safe.t option, string) result

(** [handle ctx seat cmd] handles the keyboard command, [cmd].

    {b Effects:} mutates WM state; sends River request *)
val handle
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_ipc.Command.Input.Keyboard.t
  -> (Yojson.Safe.t option, string) result
