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

(** [shift seat dir] shifts the focused window one slot in [dir] through the
    tile stack, wrapping at the head and tail. Is [Error msg] when [seat] has no
    output, no window is focused, or no other window exists.

    {b Effects:} mutates WM state *)
val shift
  :  Oxbow_state.Seat.t
  -> Oxbow_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result
