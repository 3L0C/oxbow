include module type of Types.Seat

(** [refresh_cursor_target seat] syncs [seat]'s cursor targed with [seat]'s
    hovered if hovered is [Some window]. No-op when hovered is [None].

    {b Effects:} mutates WM state *)
val refresh_cursor_target : t -> unit

(** [queue_pending seat request] adds [request] to [seat]'s queue.

    {b Effects:} mutates WM state *)
val queue_pending : t -> Pending_request.t -> unit

(** [drain_pending seat] removes and returns the next pending request on [seat],
    or [None] when the queue is empty.

    {b Effects:} mutates WM state *)
val drain_pending : t -> Pending_request.t option

(** [clear_pending seat] discards every pending request on [seat].

    {b Effects:} mutates WM state *)
val clear_pending : t -> unit

(** [set_output seat output] sets [seat]'s output to [output].

    {b Effects:} mutates WM state *)
val set_output : t -> Types.Output.t option -> unit

(** [set_focus_cleared seat cleared] sets [seat]'s focus cleared state to
    [cleared].

    {b Effects:} mutates WM state *)
val set_focus_cleared : t -> bool -> unit

(** [focus_output seat output] moves [seat]'s focus to [output] if [output] is
    not already focused.

    {b Effects:} mutates WM state *)
val focus_output : t -> Types.Output.t option -> unit

(** [set_layer_focus seat layer] sets [seat]'s focused layer to [layer].

    {b Effects:} mutates WM state *)
val set_layer_focus : t -> Layer_focus.t option -> unit

(** [set_mode wm seat mode] sets [seat]'s current mode to [mode]. Is
    [Error msg] when [mode] is not declared or is [Mode.locked].

    {b Effects:} mutates WM state *)
val set_mode : Types.Wm.t -> t -> string -> (unit, string) result

(** [set_position seat (x, y)] positions [seat] at [(x, y)].

    {b Effects:} mutates WM state *)
val set_position : t -> int32 * int32 -> unit

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

(** [set_warp_pending seat pending] sets [seat]'s warp pending flag to
    [pending].

    {b Effects:} mutates WM state *)
val set_warp_request : t -> Warp_request.t -> unit

(** [set_overview_watch seat watch] sets [watch] as [seat]'s watched modifiers
    for overview mode.

    {b Effects:} mutates WM state *)
val set_overview_watch : t -> int32 -> unit

(** [set_watch_sent seat sent] sets [sent] as [seat]'s watched modifiers.

    {b Effects:} mutates WM state *)
val set_watch_sent : t -> int32 -> unit

(** [bind wm seat ?mode mods key command] binds the [mods] and [key] to
    [command] in [mode] (default [Mode.normal]). Replaces any existing binding
    for [mods] and [key]. Is [Ok true] when a binding was replaced. Is
    [Error msg] when [mode] is not declared.

    {b Effects:} mutates WM state *)
val bind
  :  Types.Wm.t
  -> t
  -> ?mode:string
  -> int32
  -> Types.Key.t
  -> Ocdwm_ipc.Command.t
  -> (bool, string) result

(** [unbind wm seat ?mode mods key] unbinds the command bound to [mods] and
    [key] in [mode] (default [Mode.normal]). Is [Ok true] when a binding was
    destroyed. Is [Error msg] when [mode] is not declared.

    {b Effects:} mutates WM state *)
val unbind
  :  Types.Wm.t
  -> t
  -> ?mode:string
  -> int32
  -> Types.Key.t
  -> (bool, string) result

(** [focused_window seat] is the focused window on [seat]'s output; [None] when
    the seat has no output. *)
val focused_window : t -> Types.Window.t option
