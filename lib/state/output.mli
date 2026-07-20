module Lifecycle = Types.Output.Lifecycle

type t = Types.Output.t

(** [focused_window output] is [Some window] when [output] has a focused visible
    window *)
val focused_window : t -> Types.Window.t option

(** [next_window output] is the window after the currently focused window in
    [output]'s window stack. This may be equal to {!focused_window} if it is the
    only window in the stack or [None] if there are no windows in the stack.
    Wraps at stack edges *)
val next_window : t -> Types.Window.t option

(** [prev_window output] is the window before the currently focused window in
    [output]'s window stack. This may be equal to {!focused_window} if it is the
    only window in the stack or [None] if there are no windows in the stack.
    Wraps at stack edges. *)
val prev_window : t -> Types.Window.t option

(** [to_tag_data output] is the tag data of the first selected tag of [output].
    Raises [Invalid_argument] if [output] has no selected tags. *)
val to_tag_data : t -> Config.Data.t

(** [at_point ~x ~y lst] returns the first output that contains point ([x],
    [y]). Is [None] when the point is out of bounds. *)
val at_point : x:int32 -> y:int32 -> t list -> t option

(** [destroy output] destroys the underlying Wayland objects associated with
    [output].

    {b Effects:} mutates WM state; sends River request *)
val destroy : t -> unit

(** [switch_tags ~tags output] changes the selected tags of [output] to
    [tags].  No-op if [Tag.Set.is_empty tags] is [true].

    {b Effects:} mutates WM state; marks dirty *)
val switch_tags : tags:Ocdwm_core.Tag.Set.t -> t -> unit

(** [occupied_tags output] is the tag set containing all tags with active
    windows. *)
val occupied_tags : t -> Ocdwm_core.Tag.Set.t

(** [occupied_tags output] is the tag set containing all tags with urgent
    windows. *)
val urgent_tags : t -> Ocdwm_core.Tag.Set.t

(** [current_layout_entry output] is the layout entry of the first selected tag
    on [output]. *)
val current_layout_entry : t -> Ocdwm_layout.Entry.t

(** [current_layout_params output] is the layout params of the first selected
    tag on [output]. *)
val current_layout_params : t -> Ocdwm_layout.Params.t

(** [current_layout_ctx output] is the current layout context of [output]. *)
val current_layout_ctx : t -> Ocdwm_layout.Symbol.Ctx.t

(** [tiled_windows output] is the list of tiled windows on the selected tags of
    [output]. *)
val tiled_windows : t -> Types.Window.t list

(** [set_layout_entry ~entry output] sets the first selected tag on [output]
    to the layout defined by [entry].

    {b Effects:} mutates WM state; marks dirty *)
val set_layout_entry : entry:Ocdwm_layout.Entry.t -> t -> unit

(** [has_visible_fullscreen output] is true when a window is fullscreen and tag
    visible on [output]. *)
val has_visible_fullscreen : t -> bool

(** [is_floating output] is true when the first selected tag is in the Floating
    layout. *)
val is_floating : t option -> bool

(** [set_mfact output delta] sets the mfact according to [delta] for the first
    selected tag on [output].

    {b Effects:} mutates WM state; marks dirty *)
val set_mfact : t -> float Ocdwm_core.Delta.t -> unit

(** [set_nmaster output delta] sets the nmaster according to [delta] for the
    first selected tag on [output].

    {b Effects:} mutates WM state; marks dirty *)
val set_nmaster : t -> int Ocdwm_core.Delta.t -> unit

(** [set_gaps_inner output delta] sets the gaps_inner according to [delta] for
    the first selected tag on [output].

    {b Effects:} mutates WM state; marks dirty *)
val set_gaps_inner : t -> int Ocdwm_core.Delta.t -> unit

(** [set_gaps_outer output delta] sets the gaps_outer according to [delta] for
    the first selected tag on [output].

    {b Effects:} mutates WM state; marks dirty *)
val set_gaps_outer : t -> int Ocdwm_core.Delta.t -> unit

(** [set_stack output kind] sets [output]'s stack kind to [kind] for the first
    selected tag on [output].

    {b Effects:} mutates WM state; marks dirty *)
val set_stack : t -> Ocdwm_core.Stack_kind.t -> unit

(** [set_dir output dir] sets [output]'s stacking direction to [dir] for the
    first selected tag on [output].

    {b Effects:} mutates WM state; marks dirty *)
val set_dir : t -> Ocdwm_core.Direction.Spatial.t -> unit

(** [set_wm_stack output ws] replaces [output]'s window stack with [ws].

    {b Effects:} mutates WM state; marks dirty *)
val set_wm_stack : t -> Types.Window.t list -> unit

(** [set_focus_stack output ws] replaces [output]'s focus stack with [ws].

    {b Effects:} mutates WM state *)
val set_focus_stack : t -> Types.Window.t list -> unit

(** [resolve_tag_arg arg output] returns the set of tags according to [arg]. *)
val resolve_tag_arg : Ocdwm_core.Tag.Arg.t -> t -> Ocdwm_core.Tag.Set.t

(** [to_vector output] is the vector of output. *)
val to_vector : t -> Ocdwm_core.Vector.t

(** [matches_name output name] is true iff [output]'s name is exactly [name]. *)
val matches_name : string -> t -> bool

(** [resolve_output_logical ~dir current outputs] is [Some output] in the
    logical direction [dir] from [current] or [None] if [outputs] is empty. Is
    [Some current] when [current] is the only output in [outputs]. *)
val resolve_output_logical : dir:Ocdwm_core.Direction.Logical.t -> t -> t list -> t option

(** [resolve_output_spatial ~from ~dir current outputs] is [Some output] in the
    spatial direction [dir] from [current] or [None] if no output qualifies. *)
val resolve_output_spatial
  :  from:Ocdwm_core.Vector.t
  -> dir:Ocdwm_core.Direction.Spatial.t
  -> t
  -> t list
  -> t option

(** [resolve_output_name name outputs] is the first output in [outputs] where
    [matches_name ~name output] is [true]. *)
val resolve_output_name : string -> t list -> t option

(** [set_lifecycle output lifecycle] sets [output]'s lifecycle to [lifecycle].

    {b Effects:} mutates WM state *)
val set_lifecycle : t -> Lifecycle.t -> unit

(** [set_usable output usable] sets [output]'s usable geometry to [usable].

    {b Effects:} mutates WM state; marks dirty *)
val set_usable : t -> int Ocdwm_core.Rect.t -> unit

(** [set_name output name] sets [output]'s name to [name].

    {b Effects:} mutates WM state *)
val set_name : t -> string option -> unit

(** [set_geom output geom] sets [output]'s geometry to [geom].

    {b Effects:} mutates WM state *)
val set_geom : t -> int32 Ocdwm_core.Rect.t -> unit

(** [set_arrangement output arrangement] sets [output]'s arrangment to
    [arrangement].

    {b Effects:} mutates WM state *)
val set_arrangement : t -> Ocdwm_core.Arrangement.t -> unit

(** [is_dirty output] is true when [output]'s lifecycle is [Dirty _]. *)
val is_dirty : t -> bool
