include module type of Types.Seat

(** [unbind_xkb_binding ctx seat mods keysym] destroys any binding matching
    [mods] and [keysym]. Is [true] when a binding was destroyed.

    {b Effects:} mutates WM state; sends River request *)
val unbind_xkb_binding : Ctx.manage Ctx.t -> t -> int32 -> Xkbcommon.Keysym.t -> bool

(** [replace_xkb_binding ctx seat mods keysym command] replaces the existing
    binding matching [mods] and [keysym] with [command]. Is [true] when a
    binding was replaced.

    {b Effects:} mutates WM state; sends River request *)
val replace_xkb_binding
  :  Ctx.manage Ctx.t
  -> t
  -> int32
  -> Xkbcommon.Keysym.t
  -> Ocdwm_ipc.Command.t
  -> bool

(** [unbind_pointer_binding ctx seat mods button] destroys any binding matching
    [mods] and [button]. Is [true] when a binding was destroyed.

    {b Effects:} mutates WM state; sends River request *)
val unbind_pointer_binding
  :  Ctx.manage Ctx.t
  -> t
  -> int32
  -> Ocdwm_core.Pointer_button.t
  -> bool

(** [replace_pointer_binding ctx seat mods button command] replaces the existing
    binding matching [mods] and [button] with [command]. Is [true] when a
    binding was replaced.

    {b Effects:} mutates WM state; sends River request *)
val replace_pointer_binding
  :  Ctx.manage Ctx.t
  -> t
  -> int32
  -> Ocdwm_core.Pointer_button.t
  -> Ocdwm_ipc.Command.t
  -> bool

(** [destroy ctx seat] destroys the Wayland objects underlying [seat].

    {b Effects:} mutates WM state; sends River request *)
val destroy : Ctx.manage Ctx.t -> t -> unit

(** [refresh_cursor_target seat] syncs [seat]'s cursor targed with [seat]'s
    hovered if hovered is [Some window]. No-op when hovered is [None].

    {b Effects:} mutates WM state *)
val refresh_cursor_target : t -> unit

(** [op_end ctx seat] ends any operation on [seat].

    {b Effects:} mutates WM state; sends River request *)
val op_end : Ctx.manage Ctx.t -> t -> unit

(** [queue_pending wm seat request] adds [request] to [seat]'s queue.

    {b Effects:} mutates WM state; marks dirty *)
val queue_pending : Types.Wm.t -> t -> Pending_request.t -> unit

(** [drain_pending seat] removes and returns the next pending request on [seat],
    or [None] when the queue is empty.

    {b Effects:} mutates WM state *)
val drain_pending : t -> Pending_request.t option

(** [clear_pending seat] discards every pending request on [seat].

    {b Effects:} mutates WM state *)
val clear_pending : t -> unit

(** [set_output seat output] sets [seat]'s output to [output].

    {b Effects:} mutates WM state; marks dirty *)
val set_output : t -> Types.Output.t option -> unit

(** [focus_output seat output] moves [seat]'s focus to [output] if [output] is
    not already focused.

    {b Effects:} mutates WM state *)
val focus_output : t -> Types.Output.t option -> unit

(** [set_layer_focus seat layer] sets [seat]'s focused layer to [layer].

    {b Effects:} mutates WM state; marks dirty *)
val set_layer_focus : t -> Layer_focus.t option -> unit

(** [set_position seat position] positions [seat] at [position].

    {b Effects:} mutates WM state *)
val set_position : t -> Position.t -> unit

(** [set_cursor_target seat cursor_target] sets [seat]'s cursor target to
    [cursor_target].

    {b Effects:} mutates WM state *)
val set_cursor_target : t -> Types.Window.t option -> unit

(** [set_focus_state seat state] sets [seat]'s focus state to [state].

    {b Effects:} mutates WM state *)
val set_focus_state : t -> Focus_state.t -> unit

(** [set_op seat op] sets [seat]'s current operation to [op].

    {b Effects:} mutates WM state *)
val set_op : t -> Op.t -> unit

(** [clear_op seat] clears the current operation on [seat].

    {b Effects:} mutates WM state *)
val clear_op : t -> unit

(** [set_op_delta seat dx dy] updates [seat]'s current operation deltas.

    {b Effects:} mutates WM state *)
val set_op_delta : t -> int32 -> int32 -> unit

(** [release_op seat] flags [seat]'s current operation for release. No-op
    when [seat] has no operation.

    {b Effects:} mutates WM state *)
val release_op : t -> unit

(** [set_lifecycle seat lifecycle] sets [seat]'s lifecycle to [lifecycle].

    {b Effects:} mutates WM state *)
val set_lifecycle : t -> Lifecycle.t -> unit

(** [set_name seat name] sets [seat]'s name to [name].

    {b Effects:} mutates WM state *)
val set_name : t -> string option -> unit

(** [set_hovered seat hovered] sets [seat]'s hovered window to [hovered].

    {b Effects:} mutates WM state *)
val set_hovered : t -> Types.Window.t option -> unit

(** [set_interacted seat interacted] sets [seat]'s interacted window to
    [interacted].

    {b Effects:} mutates WM state *)
val set_interacted : t -> Types.Window.t option -> unit

(** [is_dirty seat] is true when [seat]'s lifecycle is [Dirty _]. *)
val is_dirty : t -> bool

(** [bind ctx seat mods key command] binds the [mods] and [key] to [command].
    Replaces any existing binding for [mods] and [key]. Is [true] when a binding
    was replaced.

    {b Effects:} mutates WM state; sends River request *)
val bind : Ctx.manage Ctx.t -> t -> int32 -> Types.Key.t -> Ocdwm_ipc.Command.t -> bool

(** [unbind ctx seat mods key] unbinds the command bound to [mods] and [key]. Is
    [true] when a binding was destroyed.

    {b Effects:} mutates WM state; sends River request *)
val unbind : Ctx.manage Ctx.t -> t -> int32 -> Types.Key.t -> bool

(** [focused_window seat] is the focused window on [seat]'s output; [None] when
    the seat has no output. *)
val focused_window : t -> Types.Window.t option
