(** [registry] is a reference to the wayland registry. *)
val registry : Wayland.Registry.t option ref

(** [on_finished wm_box] handles the finished event.

    {b Effects:} mutates WM state *)
val on_finished : Oxbow_state.Wm.t Oxbow_state.Box.t -> unit

(** [on_manage_start river_wm_v1 wm_box] handles the manage cycle.

    {b Effects:} mutates WM state *)
val on_manage_start
  :  River.Obj.Window_management.t
  -> Oxbow_state.Wm.t Oxbow_state.Box.t
  -> unit

(** [on_output river_wm_v1 river_output wm_box] handles new output creation.

    {b Effects:} mutates WM state *)
val on_output
  :  River.Obj.Window_management.t
  -> River.Obj.Window_management.Output.t
  -> Oxbow_state.Wm.t Oxbow_state.Box.t
  -> unit

(** [on_render_start river_wm_v1 wm_box] handles the render cycle.

    {b Effects:} mutates WM state *)
val on_render_start
  :  River.Obj.Window_management.t
  -> Oxbow_state.Wm.t Oxbow_state.Box.t
  -> unit

(** [on_seat river_wm_v1 river_seat wm_box] handles new seat creation.

    {b Effects:} mutates WM state *)
val on_seat
  :  River.Obj.Window_management.t
  -> River.Obj.Window_management.Seat.t
  -> Oxbow_state.Wm.t Oxbow_state.Box.t
  -> unit

(** [on_session_locked river_wm_v1 wm_box] handles the session lock request.

    {b Effects:} mutates WM state *)
val on_session_locked
  :  River.Obj.Window_management.t
  -> Oxbow_state.Wm.t Oxbow_state.Box.t
  -> unit

(** [on_session_unlocked river_wm_v1 wm_box] handles the session unlock request.

    {b Effects:} mutates WM state *)
val on_session_unlocked
  :  River.Obj.Window_management.t
  -> Oxbow_state.Wm.t Oxbow_state.Box.t
  -> unit

(** [on_unavailable river_wm_v1] handles the unavailable event.

    {b Effects:} mutates WM state

    @raise Exceptions.Unavailable *)
val on_unavailable : River.Obj.Window_management.t -> unit

(** [on_window river_wm_v1 river_window wm_box] handles new window creation.

    {b Effects:} mutates WM state *)
val on_window
  :  River.Obj.Window_management.t
  -> River.Obj.Window_management.Window.t
  -> Oxbow_state.Wm.t Oxbow_state.Box.t
  -> unit

(** [on_input_device device wm_box] handles newly added input devices.

    {b Effects:} mutates WM state *)
val on_input_device
  :  River.Obj.Input.Management.Device.t
  -> Oxbow_state.Wm.t Oxbow_state.Box.t
  -> unit

(** [on_libinput_device device wm_box] handles newly added libinput
    devices.

    {b Effects:} mutates WM state *)
val on_libinput_device
  :  River.Obj.Input.Config.Device.t
  -> Oxbow_state.Wm.t Oxbow_state.Box.t
  -> unit

(** [on_xkb_keyboard xkb wm_box] handles newly added xkb keybords.

    {b Effects:} mutates WM state *)
val on_xkb_keyboard
  :  River.Obj.Xkb.Config.Keyboard.t
  -> Oxbow_state.Wm.t Oxbow_state.Box.t
  -> unit
