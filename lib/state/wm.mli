include module type of Types.Wm

(** [focused_output wm] is the focused output on [wm]'s primary seat, or [None]
    if no primary seat is defined or no focused output is defined for the seat. *)
val focused_output : t -> Types.Output.t option

(** [default_output wm] is [wm]'s default output. Is [None] when [wm] has no
    outputs. *)
val default_output : t -> Types.Output.t option

(** [ensure_seat_output wm seat] assigns [default_output wm] to [seat] if it has
    no current output. No-op if [seat] already has an output, or if no outputs
    exist.

    {b Effects:} mutates WM state *)
val ensure_seat_output : t -> Types.Seat.t -> unit

(** [set_primary_seat wm primary_seat] sets [wm]'s primary seat to
    [primary_seat].

    {b Effects:} mutates WM state *)
val set_primary_seat : t -> Types.Seat.t option -> unit

(** [set_outputs wm outputs] sets [wm]'s output list to [outputs].

    {b Effects:} mutates WM state *)
val set_outputs : t -> Types.Output.t list -> unit

(** [set_windows wm windows] sets [wm]'s window list to [windows].

    {b Effects:} mutates WM state *)
val set_windows : t -> Types.Window.t list -> unit

(** [set_seats wm seats] sets [wm]'s seat list to [seats].

    {b Effects:} mutates WM state *)
val set_seats : t -> Types.Seat.t list -> unit

(** [set_lifecycle wm lifecycle] sets [wm]'s lifecycle to [lifecycle].

    {b Effects:} mutates WM state *)
val set_lifecycle : t -> Lifecycle.t -> unit

(** [set_keymap wm keymap] sets [wm]'s keymap to [keymap].

    {b Effects:} mutates WM state *)
val set_keymap : t -> Wire.Obj.Xkb.Config.Keymap.t option -> unit

(** [set_desired_keymap_path wm desired_keymap_path] sets [wm]'s keymap path to
    [desired_keymap_path].

    {b Effects:} mutates WM state *)
val set_desired_keymap_path : t -> string option -> unit

(** [set_init_handle wm init_handle] sets [wm]'s init hanled to [init_handle].

    {b Effects:} mutates WM state *)
val set_init_handle : t -> Init_script.t option -> unit

(** [set_input_devices wm input_devices] sets [wm]'s input device list to
    [input_devices].

    {b Effects:} mutates WM state *)
val set_input_devices : t -> Types.Input_device.t list -> unit

(** [add_xkb_stash wm device xkb] adds [(device, xkb)] to [wm]'s pending xkb
    list.

    {b Effects:} mutates WM state *)
val add_xkb_stash : t -> int32 -> Wire.Obj.Xkb.Config.Keyboard.t -> unit

(** [remove_xkb_stash wm device] removes all pending xkb entries matching
    [device].

    {b Effects:} mutates WM state *)
val remove_xkb_stash : t -> int32 -> unit

(** [find_xkb_stash_opt wm device] is the pending xkb object matching [device]
    or [None]. *)
val find_xkb_stash_opt : t -> int32 -> Wire.Obj.Xkb.Config.Keyboard.t option

(** [add_input_device wm device] adds [device] to [wm]'s input device list.

    {b Effects:} mutates WM state *)
val add_input_device : t -> Types.Input_device.t -> unit

(** [remove_input_device wm device] removes [device] from [wm]'s input device
    list.

    {b Effects:} mutates WM state *)
val remove_input_device : t -> Types.Input_device.t -> unit

(** [find_window_opt wm id] is the window of [wm] whose river object is [id].
    Is [None] when no window matches. *)
val find_window_opt : t -> int32 -> Types.Window.t option

(** [find_seat_opt wm id] is the seat of [wm] whose river object is [id]. Is
    [None] when no seat matches. *)
val find_seat_opt : t -> int32 -> Types.Seat.t option

(** [find_output_opt wm id] is the output of [wm] whose river object is [id].
    Is [None] when no output matches. *)
val find_output_opt : t -> int32 -> Types.Output.t option

(** [find_input_device_opt wm id] is the input device matching [id]. Is [None]
    when no input device matches. *)
val find_input_device_opt : t -> int32 -> Types.Input_device.t option

(** [add_subscriber wm sub] registers [sub] to receive published events.

    {b Effects:} mutates WM state *)
val add_subscriber : t -> Ipc.Subscriber.t -> unit

(** [remove_subscriber wm sub] removes [sub] from the subscriber registry; no-op
    when [sub] is not registered.

    {b Effects:} mutates WM state *)
val remove_subscriber : t -> Ipc.Subscriber.t -> unit

(** [set_session_locked wm locked] records whether the session is locked.

    {b Effects:} mutates WM state *)
val set_session_locked : t -> bool -> unit
