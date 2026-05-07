module Rwm = Ocdwm_protocol.River_window_management_v1_client

(** [on_finished wm_box] handles the finished event.

    {b Effects:} mutates WM state *)
val on_finished : Types.Window_manager.t Box.t -> unit

(** [on_manage_start river_wm_v1 wm_box] handles the manage cycle.

    {b Effects:} mutates WM state; sends River request *)
val on_manage_start
  :  [ `V4 ] Rwm.River_window_manager_v1.t
  -> Types.Window_manager.t Box.t
  -> unit

(** [on_output river_wm_v1 river_output wm_box] handles new output creation.

    {b Effects:} mutates WM state; sends River request *)
val on_output
  :  [ `V4 ] Rwm.River_window_manager_v1.t
  -> [ `V4 ] Rwm.River_output_v1.t
  -> Types.Window_manager.t Box.t
  -> unit

(** [on_render_start river_wm_v1 wm_box] handles the render cycle.

    {b Effects:} mutates WM state; sends River request *)
val on_render_start
  :  [ `V4 ] Rwm.River_window_manager_v1.t
  -> Types.Window_manager.t Box.t
  -> unit

(** [on_seat river_wm_v1 river_seat wm_box] handles new seat creation.

    {b Effects:} mutates WM state; sends River request *)
val on_seat
  :  [ `V4 ] Rwm.River_window_manager_v1.t
  -> [ `V4 ] Rwm.River_seat_v1.t
  -> Types.Window_manager.t Box.t
  -> unit

(** [on_session_locked river_wm_v1] handles the session lock request.

    {b Effects:} mutates WM state; sends River request *)
val on_session_locked : [ `V4 ] Rwm.River_window_manager_v1.t -> unit

(** [on_session_unlocked river_wm_v1] handles the session unlock request.

    {b Effects:} mutates WM state; sends River request *)
val on_session_unlocked : [ `V4 ] Rwm.River_window_manager_v1.t -> unit

(** [on_unavailable river_wm_v1] handles the unavailable event.

    {b Effects:} mutates WM state

    @raise Exceptions.Unavailable *)
val on_unavailable : [ `V4 ] Rwm.River_window_manager_v1.t -> unit

(** [on_window river_wm_v1 river_window wm_box] handles new window creation.

    {b Effects:} mutates WM state; sends River request *)
val on_window
  :  [ `V4 ] Rwm.River_window_manager_v1.t
  -> [ `V4 ] Rwm.River_window_v1.t
  -> Types.Window_manager.t Box.t
  -> unit
