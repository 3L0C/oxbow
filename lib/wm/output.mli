module Tag_set = Ocdwm_core.Tag_set
open Ocdwm_layout.Types

type t = Types.Output_t.t

(** [focused_window output] is [Some window] when [output] has a focused visible
    window *)
val focused_window : t -> Window.t option

(** [focus_window window] focuses [window].

    {b Effects:} mutates WM state *)
val focus_window : Window.t -> unit

(** [next_window output] is the window after the currently focused window in
    [output]'s window stack. This may be equal to {!focused_window} if it is the
    only window in the stack or [None] if there are no windows in the stack.
    Wraps at stack edges *)
val next_window : t -> Window.t option

(** [prev_window output] is the window before the currently focused window in
    [output]'s window stack. This may be equal to {!focused_window} if it is the
    only window in the stack or [None] if there are no windows in the stack.
    Wraps at stack edges. *)
val prev_window : t -> Window.t option

(** [remove_window ~window output] removes [window] from [output] if [output]
    manages [window].

    {b Effects:} mutates WM state *)
val remove_window : window:Window.t -> t -> unit

(** [at_point ~x ~y lst] returns the first output that contains point ([x],
    [y]).  Returns [None] when the point is output of bounds. *)
val at_point : x:int32 -> y:int32 -> t list -> t option

(** [move_window window output] removes [window] from its current output, if
    any, and moves it to [output]. No-op when [window] is already owned by
    [output].

    {b Effects:} mutates WM state *)
val move_window : Window.t -> t -> unit

(** [mark_dirty output] flags [output] as "dirty" for rendering purposes.

    {b Effects:} mutates WM state *)
val mark_dirty : t -> unit

(** [add_window ~window output] adds [window] to [output]'s managed windows.

    {b Effects:} mutates WM state *)
val add_window : window:Window.t -> t -> unit

(** [destroy output] destroys the underlying Wayland objects associated with
    [output].

    {b Effects:} mutates WM state; sends River request *)
val destroy : t -> unit

(** [retile ctx output] arranges [output]'s managed windows.

    {b Effects:} mutates WM state; sends River request *)
val retile : Ctx.manage Ctx.t -> t -> unit

(** [switch_tags output tags] changes the selected tags of [output] to [tags].
    No-op if [Tag_set.is_empty tags] is [true].

    {b Effects:} mutates WM state *)
val switch_tags : t -> Tag_set.t -> unit

(** [occupied_tags output] is the tag set containing all tags with active
    windows. *)
val occupied_tags : t -> Tag_set.t

(** [current_layout_entry output] is the layout entry for the first selected tag
    on [output]. *)
val current_layout_entry : t -> Layout_entry.t

(** [tiled_windows output] is the list of tiled windows on the selected tags of
    [output]. *)
val tiled_windows : t -> Window.t list

(** [set_layout_entry output ~entry] set's the first selected tag on [output] to
    [entry].

    {b Effects:} mutates WM state *)
val set_layout_entry : t -> entry:Layout_entry.t -> unit
