(** [manage wm proxy] runs on manage phase; behavior branches
    on [wm]'s lifecycle.

    {b Effects:} mutates WM state; sends River request *)
val manage
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.River.V.Window_management.t
       Ocdwm_state.River.Window_management.River_window_manager_v1.t
  -> unit

(** [render wm proxy] runs one render phase.

    {b Effects:} sends River request *)
val render
  :  Ocdwm_state.Wm.t
  -> Ocdwm_state.River.V.Window_management.t
       Ocdwm_state.River.Window_management.River_window_manager_v1.t
  -> unit
