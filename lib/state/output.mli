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

(** [tag_data output tags] is the tag data of [output] the first set tag of
    [tags]. Raises [Invalid_argument] if [tags] is the empty set. *)
val tag_data : t -> Oxbow_core.Tag.Set.t -> Config.Data.t

(** [to_tag_data output] is the tag data of the first selected tag of [output].
    Raises [Invalid_argument] if [output] has no selected tags. *)
val to_tag_data : t -> Config.Data.t

(** [at_point ~x ~y lst] returns the first output that contains point ([x],
    [y]). Is [None] when the point is out of bounds. *)
val at_point : x:int32 -> y:int32 -> t list -> t option

(** [switch_tags ~tags output] changes the selected tags of [output] to
    [tags].  No-op if [Tag.Set.is_empty tags] is [true].

    {b Effects:} mutates WM state *)
val switch_tags : tags:Oxbow_core.Tag.Set.t -> t -> unit

(** [occupied_tags output] is the tag set containing all tags with active
    windows. *)
val occupied_tags : t -> Oxbow_core.Tag.Set.t

(** [occupied_tags output] is the tag set containing all tags with urgent
    windows. *)
val urgent_tags : t -> Oxbow_core.Tag.Set.t

(** [current_layout output] is the layout of the first selected tag of [output]. *)
val current_layout : t -> Oxbow_core.Layout.t

(** [current_scheme output] is the scheme of the first selected tag of
    [output]. *)
val current_scheme : t -> Oxbow_core.Scheme.t

(** [windows_on_tags output ~tags] is the list of [output]'s windows on [tags]. *)
val windows_on_tags : t -> tags:Oxbow_core.Tag.Set.t -> Types.Window.t list

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

(** [apply_layout td ~layout] applies [layout] to the layout of [td].

    {b Effects:} mutates WM state *)
val apply_layout : Types.Config.Data.t -> layout:Oxbow_core.Layout.t -> unit

(** [apply_scheme td ~scheme] applies [scheme] to the scheme of [td].

    {b Effects:} mutates WM state *)
val apply_scheme : Types.Config.Data.t -> scheme:Oxbow_core.Scheme.t -> unit

(** [enter_overview output] activates overview mode for [output] if not already
    active.

    {b Effects:} mutates WM state *)
val enter_overview : t -> unit

(** [exit_overview output] deactivates overview mode for [output] if active.

    {b Effects:} mutates WM state *)
val exit_overview : t -> unit

(** [apply_mfact td ~delta] applies [delta] to the mfact of [td].

    {b Effects:} mutates WM state *)
val apply_mfact : Types.Config.Data.t -> delta:float Oxbow_core.Delta.t -> unit

(** [apply_nmaster td ~delta] applies [delta] to the nmaster of [td]

    {b Effects:} mutates WM state *)
val apply_nmaster : Types.Config.Data.t -> delta:int Oxbow_core.Delta.t -> unit

(** [apply_gaps_inner td ~delta] applies [delta] to the inner gaps of [td].

    {b Effects:} mutates WM state *)
val apply_gaps_inner : Types.Config.Data.t -> delta:int Oxbow_core.Delta.t -> unit

(** [apply_gaps_outer td ~delta] applies [delta] to the outer gaps of [td].

    {b Effects:} mutates WM state *)
val apply_gaps_outer : Types.Config.Data.t -> delta:int Oxbow_core.Delta.t -> unit

(** [apply_scroll_align td ~align] applies [align] to the scroll layout of [td].

    {b Effects:} mutates WM state *)
val apply_scroll_align : Types.Config.Data.t -> align:Oxbow_core.Align.t -> unit

(** [apply_orientation td ~dir] applies [dir] to the orientation of [td].

    {b Effects:} mutates WM state *)
val apply_orientation : Types.Config.Data.t -> dir:Oxbow_core.Direction.Spatial.t -> unit

(** [set_gaps_overview output ~delta] sets the overview gaps for [output]
    according to [delta].

    {b Effects:} mutates WM state *)
val set_gaps_overview : t -> delta:int Oxbow_core.Delta.t -> unit

(** [set_overview_head output head] sets [head] as the first window of overview
    mode for [output].

    {b Effects:} mutates WM state *)
val set_overview_head : t -> Types.Window.t option -> unit

(** [set_wm_stack output ws] replaces [output]'s window stack with [ws].

    {b Effects:} mutates WM state *)
val set_wm_stack : t -> Types.Window.t list -> unit

(** [set_focus_stack output ws] replaces [output]'s focus stack with [ws].

    {b Effects:} mutates WM state *)
val set_focus_stack : t -> Types.Window.t list -> unit

(** [resolve_tag_arg ~arg output] returns the set of tags according to [arg]. *)
val resolve_tag_arg : arg:Oxbow_core.Tag.Arg.t -> t -> Oxbow_core.Tag.Set.t

(** [to_vector output] is the vector of output. *)
val to_vector : t -> Oxbow_core.Vector.t

(** [matches_name output name] is true iff [output]'s name is exactly [name]. *)
val matches_name : string -> t -> bool

(** [resolve_output_logical ~dir current outputs] is [Some output] in the
    logical direction [dir] from [current] or [None] if [outputs] is empty. Is
    [Some current] when [current] is the only output in [outputs]. *)
val resolve_output_logical : dir:Oxbow_core.Direction.Logical.t -> t -> t list -> t option

(** [resolve_output_spatial ~from ~dir current outputs] is [Some output] in the
    spatial direction [dir] from [current] or [None] if no output qualifies. *)
val resolve_output_spatial
  :  from:Oxbow_core.Vector.t
  -> dir:Oxbow_core.Direction.Spatial.t
  -> t
  -> t list
  -> t option

(** [resolve_output_name name outputs] is the first output in [outputs] where
    [matches_name ~name output] is [true]. *)
val resolve_output_name : string -> t list -> t option

(** [set_lifecycle output lifecycle] sets [output]'s lifecycle to [lifecycle].

    {b Effects:} mutates WM state *)
val set_lifecycle : t -> Lifecycle.t -> unit

(** [set_is_captured output is_captured] sets [output]'s captured status to
    [is_captured].

    {b Effects:} mutates WM state *)
val set_is_captured : t -> bool -> unit

(** [set_usable output usable] sets [output]'s usable geometry to [usable].

    {b Effects:} mutates WM state *)
val set_usable : t -> int Oxbow_core.Rect.t -> unit

(** [set_name output name] sets [output]'s name to [name].

    {b Effects:} mutates WM state *)
val set_name : t -> string option -> unit

(** [add_label output label] adds [label] to [output]'s label set. No-op when
    the label is present.

    {b Effects:} mutates WM state *)
val add_label : t -> string -> unit

(** [remove_label output label] removes [label] from [output]'s label set. No-op
    when label is absent.

    {b Effects:} mutates WM state *)
val remove_label : t -> string -> unit

(** [set_geom output geom] sets [output]'s geometry to [geom].

    {b Effects:} mutates WM state *)
val set_geom : t -> int32 Oxbow_core.Rect.t -> unit

(** [set_scroll_offset output offset] sets the scroll offset of the first active
    tag on [output].

    {b Effects:} mutates WM state *)
val set_scroll_offset : t -> int -> unit

(** [apply_default_width td ~delta] applies [delta] to the default width of [td].

    {b Effects:} mutates WM state *)
val apply_default_width : Types.Config.Data.t -> delta:float Oxbow_core.Delta.t -> unit

(** [arranges window] is true when [window]'s output owns its dimensions and a
    proposal exists to defend. *)
val arranges : Types.Window.t -> bool
