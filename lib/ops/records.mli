(** [to_tags output] is a tag record derived from [output]. Is [None]
    when [output] has no name. *)
val to_tags : Ocdwm_state.Output.t -> Ocdwm_ipc.Record.Tags.t option

(** [to_window wm window] is a window record derived from [wm] and [window]. *)
val to_window : Ocdwm_state.Wm.t -> Ocdwm_state.Window.t -> Ocdwm_ipc.Record.Window.t

(** [to_layout output] is a layout record derived from [output]. Is [None] when
    [output] has no name. *)
val to_layout : Ocdwm_state.Output.t -> Ocdwm_ipc.Record.Layout.t option

(** [to_mode seat] is a mode record derived from [seat]. Is [None] when [seat] *)
val to_mode : Ocdwm_state.Seat.t -> Ocdwm_ipc.Record.Mode.t option

(** [to_focus seat] is a focus record derived from [seat]. Is [None] when [seat]
    has no name. *)
val to_focus : Ocdwm_state.Seat.t -> Ocdwm_ipc.Record.Focus.t option
