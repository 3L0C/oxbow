(** [on_finished wm_box] handles the finished event.

    {b Effects:} mutates WM state *)
val on_finished : Ocdwm_state.Wm.t Ocdwm_state.Box.t -> unit

(** [on_manage_start river_wm_v1 wm_box] handles the manage cycle.

    {b Effects:} mutates WM state; sends River request *)
val on_manage_start
  :  Ocdwm_state.River.V.Window_management.t
       Ocdwm_state.River.Window_management.River_window_manager_v1.t
  -> Ocdwm_state.Wm.t Ocdwm_state.Box.t
  -> unit

(** [on_output river_wm_v1 river_output wm_box] handles new output creation.

    {b Effects:} mutates WM state; sends River request *)
val on_output
  :  Ocdwm_state.River.V.Window_management.t
       Ocdwm_state.River.Window_management.River_window_manager_v1.t
  -> Ocdwm_state.River.V.Window_management.t
       Ocdwm_state.River.Window_management.River_output_v1.t
  -> Ocdwm_state.Wm.t Ocdwm_state.Box.t
  -> unit

(** [on_render_start river_wm_v1 wm_box] handles the render cycle.

    {b Effects:} mutates WM state; sends River request *)
val on_render_start
  :  Ocdwm_state.River.V.Window_management.t
       Ocdwm_state.River.Window_management.River_window_manager_v1.t
  -> Ocdwm_state.Wm.t Ocdwm_state.Box.t
  -> unit

(** [on_seat river_wm_v1 river_seat wm_box] handles new seat creation.

    {b Effects:} mutates WM state; sends River request *)
val on_seat
  :  Ocdwm_state.River.V.Window_management.t
       Ocdwm_state.River.Window_management.River_window_manager_v1.t
  -> Ocdwm_state.River.V.Window_management.t
       Ocdwm_state.River.Window_management.River_seat_v1.t
  -> Ocdwm_state.Wm.t Ocdwm_state.Box.t
  -> unit

(** [on_session_locked river_wm_v1 wm_box] handles the session lock request.

    {b Effects:} mutates WM state; sends River request *)
val on_session_locked
  :  Ocdwm_state.River.V.Window_management.t
       Ocdwm_state.River.Window_management.River_window_manager_v1.t
  -> Ocdwm_state.Wm.t Ocdwm_state.Box.t
  -> unit

(** [on_session_unlocked river_wm_v1 wm_box] handles the session unlock request.

    {b Effects:} mutates WM state; sends River request *)
val on_session_unlocked
  :  Ocdwm_state.River.V.Window_management.t
       Ocdwm_state.River.Window_management.River_window_manager_v1.t
  -> Ocdwm_state.Wm.t Ocdwm_state.Box.t
  -> unit

(** [on_unavailable river_wm_v1] handles the unavailable event.

    {b Effects:} mutates WM state

    @raise Exceptions.Unavailable *)
val on_unavailable
  :  Ocdwm_state.River.V.Window_management.t
       Ocdwm_state.River.Window_management.River_window_manager_v1.t
  -> unit

(** [on_window river_wm_v1 river_window wm_box] handles new window creation.

    {b Effects:} mutates WM state; sends River request *)
val on_window
  :  Ocdwm_state.River.V.Window_management.t
       Ocdwm_state.River.Window_management.River_window_manager_v1.t
  -> Ocdwm_state.River.V.Window_management.t
       Ocdwm_state.River.Window_management.River_window_v1.t
  -> Ocdwm_state.Wm.t Ocdwm_state.Box.t
  -> unit

(** [on_input_device device wm_box] handles newly added input devices.

    {b Effects:} mutates WM state; sends River request *)
val on_input_device
  :  Ocdwm_state.River.V.Input_management.t
       Ocdwm_state.River.Input_management.River_input_device_v1.t
  -> Ocdwm_state.Wm.t Ocdwm_state.Box.t
  -> unit

(** [on_xkb_keyboard xkb wm_box] handles newly added xkb keybords.

    {b Effects:} mutates WM state; sends River request *)
val on_xkb_keyboard
  :  Ocdwm_state.River.V.Xkb_config.t Ocdwm_state.River.Xkb_config.River_xkb_keyboard_v1.t
  -> Ocdwm_state.Wm.t Ocdwm_state.Box.t
  -> unit
