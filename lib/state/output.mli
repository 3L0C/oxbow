include module type of Types.Output

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

(** [switch_tags ~tags output] changes the selected tags of [output] to
    [tags].  No-op if [Tag.Set.is_empty tags] is [true].

    {b Effects:} mutates WM state *)
val switch_tags : tags:Ocdwm_core.Tag.Set.t -> t -> unit

(** [occupied_tags output] is the tag set containing all tags with active
    windows. *)
val occupied_tags : t -> Ocdwm_core.Tag.Set.t

(** [occupied_tags output] is the tag set containing all tags with urgent
    windows. *)
val urgent_tags : t -> Ocdwm_core.Tag.Set.t

(** [current_layout output] is the layout of the first selected tag of [output]. *)
val current_layout : t -> Ocdwm_core.Layout.t

(** [current_scheme output] is the scheme of the first selected tag of
    [output]. *)
val current_scheme : t -> Ocdwm_core.Scheme.t

(** [windows_on_tags output ~tags] is the list of [output]'s windows on [tags]. *)
val windows_on_tags : t -> tags:Ocdwm_core.Tag.Set.t -> Types.Window.t list

(** [visible_windows output] is the list of visible windows on the selected tags
    of [output]. *)
val visible_windows : t -> Types.Window.t list

(** [visible_window_count output] is the length of [visible_windows o]. *)
val visible_window_count : t -> int

(** [tiled_windows output] is the list of tiled windows on the selected tags of
    [output]. *)
val tiled_windows : t -> Types.Window.t list

(** [has_visible_fullscreen output] is true when a window is fullscreen and tag
    visible on [output]. *)
val has_visible_fullscreen : t -> bool

(** [is_floating output] is true when [output] is in the [Floating] layout. *)
val is_floating : t option -> bool

(** [set_layout output layout ~global] sets the layout of [output]. Applied to
    all tags when [global] is true. Applied to the first selected tags when
    [false].

    {b Effects:} mutates WM state *)
val set_layout : t -> Ocdwm_core.Layout.t -> global:bool -> unit

(** [set_scheme output scheme ~global] sets the scheme of [output]. Applied to
    all tags when [global] is true. Applied to the first selected tags when
    [false].

    {b Effects:} mutates WM state *)
val set_scheme : t -> Ocdwm_core.Scheme.t -> global:bool -> unit

(** [cycle_scheme output dir ~global] sets [output]'s tiling scheme to the [dir]
    scheme. Applied to all tags when [global] is true. Applied to the first
    selected tags when [false].

    {b Effects:} mutates WM state *)
val cycle_scheme : t -> Ocdwm_core.Direction.Logical.t -> global:bool -> unit

(** [enter_overview output] activates overview mode for [output] if not already
    active.

    {b Effects:} mutates WM state *)
val enter_overview : t -> unit

(** [exit_overview output] deactivates overview mode for [output] if active.

    {b Effects:} mutates WM state *)
val exit_overview : t -> unit

(** [set_mfact output delta ~global] sets the mfact according to [delta] for the
    first selected tag on [output]. When [global] is [true], the change applies
    to every tag.

    {b Effects:} mutates WM state *)
val set_mfact : t -> float Ocdwm_core.Delta.t -> global:bool -> unit

(** [set_nmaster output delta ~global] sets the nmaster according to [delta] for
    the first selected tag on [output]. When [global] is [true], the change
    applies to every tag.

    {b Effects:} mutates WM state *)
val set_nmaster : t -> int Ocdwm_core.Delta.t -> global:bool -> unit

(** [set_gaps_inner output delta ~global] sets the gaps_inner according to
    [delta] for the first selected tag on [output]. When [global] is [true], the
    change applies to every tag.

    {b Effects:} mutates WM state *)
val set_gaps_inner : t -> int Ocdwm_core.Delta.t -> global:bool -> unit

(** [set_gaps_outer output delta ~global] sets the gaps_outer according to
    [delta] for the first selected tag on [output]. When [global] is [true], the
    change applies to every tag.

    {b Effects:} mutates WM state *)
val set_gaps_outer : t -> int Ocdwm_core.Delta.t -> global:bool -> unit

(** [set_gaps_overview output ~delta] sets the overview gaps for [output]
    according to [delta].

    {b Effects:} mutates WM state *)
val set_gaps_overview : t -> delta:int Ocdwm_core.Delta.t -> unit

(** [set_overview_head output head] sets [head] as the first window of overview
    mode for [output].

    {b Effects:} mutates WM state *)
val set_overview_head : t -> Types.Window.t option -> unit

(** [set_scroll_policy output policy ~global] sets [output]'s scrolling policy to
    [policy]. Applied to all tags when [global] is true. Applied to the first
    selected tags when [false].

    {b Effects:} mutates WM state *)
val set_scroll_policy : t -> Ocdwm_core.Scroll_policy.t -> global:bool -> unit

(** [set_orientation output dir ~global] sets [output]'s stacking orientation to
    [dir]. Applied to all tags when [global] is true. Applied to the first
    selected tags when [false].

    {b Effects:} mutates WM state *)
val set_orientation : t -> Ocdwm_core.Direction.Spatial.t -> global:bool -> unit

(** [set_wm_stack output ws] replaces [output]'s window stack with [ws].

    {b Effects:} mutates WM state *)
val set_wm_stack : t -> Types.Window.t list -> unit

(** [set_focus_stack output ws] replaces [output]'s focus stack with [ws].

    {b Effects:} mutates WM state *)
val set_focus_stack : t -> Types.Window.t list -> unit

(** [resolve_tag_arg ~arg output] returns the set of tags according to [arg]. *)
val resolve_tag_arg : arg:Ocdwm_core.Tag.Arg.t -> t -> Ocdwm_core.Tag.Set.t

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

    {b Effects:} mutates WM state *)
val set_usable : t -> int Ocdwm_core.Rect.t -> unit

(** [set_name output name] sets [output]'s name to [name].

    {b Effects:} mutates WM state *)
val set_name : t -> string option -> unit

(** [set_geom output geom] sets [output]'s geometry to [geom].

    {b Effects:} mutates WM state *)
val set_geom : t -> int32 Ocdwm_core.Rect.t -> unit

(** [set_scroll_offset output offset] sets [output]'s scroll offset to [offset].

    {b Effects:} mutates WM state *)
val set_scroll_offset : t -> int -> unit

(** [set_default_width output delta ~global] sets the default column width
    according to [delta]. Applied to all tags when [global] is true. Applied to
    the first selected tags when [false].

    {b Effects:} mutates WM state *)
val set_default_width : t -> float Ocdwm_core.Delta.t -> global:bool -> unit
