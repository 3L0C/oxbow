(** [remove_window ~window output] removes [window] from [output] if [output]
    manages [window].

    {b Effects:} mutates WM state *)
val remove_window : window:Oxbow_state.Window.t -> Oxbow_state.Output.t -> unit

(** [restore_focus_order ~like output] reorders [output]'s focus stack. Windows
    that appear in [like] come first, in the order of [like]. The other windows
    keep their current order.

    {b Effects:} mutates WM state *)
val restore_focus_order : like:Oxbow_state.Window.t list -> Oxbow_state.Output.t -> unit

(** [push windows output] pushes [windows] to the top of the tile and focus stack
    of [output].

    {b Effects:} mutates WM state *)
val push : Oxbow_state.Window.t list -> Oxbow_state.Output.t -> unit

(** [focus_window window] focuses [window].

    {b Effects:} mutates WM state *)
val focus_window : Oxbow_state.Window.t -> unit

(** [shift wm seat target dir] shifts the window [target] one slot in [dir]
    through the tile stack, wrapping at the head and tail. Is [Error msg] when
    the [target] window has no output, or no other window exists.

    {b Effects:} mutates WM state *)
val shift
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Target.Window.One.t
  -> Oxbow_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [replace ~old_w ~new_w output] puts [new_w] in [old_w]'s slot in [output]'s
    wm and focus stacks. [new_w] leaves any other slot it held. [old_w] leaves
    both stacks.

    {b Effects:} mutates WM state *)
val replace
  :  old_w:Oxbow_state.Window.t
  -> new_w:Oxbow_state.Window.t
  -> Oxbow_state.Output.t
  -> unit
