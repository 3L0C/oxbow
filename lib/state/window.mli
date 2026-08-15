include module type of Types.Window

(** [create wm output river_window] is a unique window. *)
val create
  :  Types.Output.t option
  -> Oxbow_core.Width_fac.t
  -> Wire.Obj.Window_management.Window.t
  -> t

(** [destroy window] destroys the Wayland objects backing [window].
    No-op (with a warning) when [window]'s lifecycle isn't [Closing]. *)
val destroy : t -> unit

(** [set_position window ~x ~y] positions [window] at ([x], [y]).

    {b Effects:} mutates WM state *)
val set_position : t -> x:int32 -> y:int32 -> unit

(** [set_geom window geom] updates [window]'s geometry to [geom].

    {b Effects:} mutates WM state *)
val set_geom : t -> int32 Oxbow_core.Rect.t -> unit

(** [set_defense window d] updates [window]'s defense state to [d].

    {b Effects:} mutates WM state *)
val set_defense : t -> Defense.t -> unit

(** [set_proposed window dims] updates [window]'s proposed dimensions to [dims].

    {b Effects:} mutates WM state *)
val set_proposed : t -> (int32 * int32) option -> unit

(** [push_in_flight window dims] records the proposed [dims] not yet echoed.

    {b Effects:} mutates WM state *)
val push_in_flight : t -> int32 * int32 -> unit

(** [consume_in_flight window ~width ~height] is [true] when the size matches an
    entry. Entries older than the newest match drop; the match stays (one
    proposal can produce the same report more than once). On [false] the list
    clears.

    {b Effects:} mutates WM state *)
val consume_in_flight : t -> width:int32 -> height:int32 -> bool

(** [set_fullscreen_on window output] updates [window]'s fullscreen output.

    {b Effects:} mutates WM state *)
val set_fullscreen_on : t -> int32 option -> unit

(** [set_clip window clip] updates [window]'s clip mask to [clip].

    {b Effects:} mutates WM state *)
val set_clip : t -> ([ `Scrolling | `Overview ] * int Oxbow_core.Rect.t) option -> unit

(** [set_clip_within window ~tag ~bw ~bound] sets [window]'s clip to according
    to [tag] when [window] intersets with [bound].

    {b Effects:} mutates WM state *)
val set_clip_within
  :  t
  -> tag:[ `Scrolling | `Overview ]
  -> bw:int
  -> bound:int Oxbow_core.Rect.t option
  -> unit

(** [set_offscreen window v] marks [window] outside the viewport in scrolling
    layouts.

    {b Effects:} mutates WM state *)
val set_offscreen : t -> bool -> unit

(** [reject_dimensions window ~width ~height] records a client size report that
    does not match the layout. At most one bounce starts per distinct size.

    {b Effects:} mutates WM state *)
val reject_dimensions : t -> width:int32 -> height:int32 -> unit

(** [on_tags window ~tags] is true when [window]'s tags intersect with [tags]. *)
val on_tags : t -> tags:Oxbow_core.Tag.Set.t -> bool

(** [occupied_tags ?except windows] is the union of the tags of [windows]. The
    tags of [except] do not count. *)
val occupied_tags : ?except:t -> t list -> Oxbow_core.Tag.Set.t

(** [tag_visible window] is [true] if [window]'s output is in overview mode or
    [window]'s tags intersect its output's selected tags. Is [false] otherwise.
    A stashed scratchpad is never tag-visible. *)
val tag_visible : t -> bool

(** [is_tiled window] is [true] when [window] is tiled. *)
val is_tiled : t -> bool

(** [is_tiled_or_floating window] is [true] when [window] is tiled or floating. *)
val is_tiled_or_floating : t -> bool

(** [scroll_clipped w] is [true] when [w] has a [`Scrolling] clip, is tiled and
    the layout of [w]'s output is [Scrolling]. *)
val scroll_clipped : t -> bool

(** [floats w o] is [true] when [w] renders as a floating window on [o]. A
    window renders as floating when its presentation is [Floating], or it is
    tiled and the layout of [o] is [Floating]. *)
val floats : t -> Types.Output.t -> bool

(** [is_tiled_on_tag window] is [tag_visible window && is_tiled window] *)
val is_tiled_on_tag : t -> bool

(** [swallowing window] is [true] when [window] hides a terminal. *)
val swallowing : t -> bool

(** [can_swallow window] is [true] when window is able to swallow its child. *)
val can_swallow : t -> bool

(** [fit_to_output window] repositions and resizes [window] to fit on the output
    it is displayed on.

    {b Effects:} mutates WM state *)
val fit_to_output : t -> unit

(** [remember_float window] saves [window]'s current geometry to restore when
    [window] transitions to the floating state.

    {b Effects:} mutates WM state *)
val remember_float : t -> unit

(** [restore_float window] places [window] at its remembered float on its
    current output. If [window] has no remembered float, it seeds at half the
    usable area, centered.  The seed is then the remembered float.

    {b Effects:} mutates WM state *)
val restore_float : t -> unit

(** [center_float window] centers [window]'s current dimensions in the usable
    area and records the result.

    {b Effects:} mutates WM state *)
val center_float : t -> unit

(** [tile window] puts [window] into the tiled state.

    {b Effects:} mutates WM state *)
val tile : t -> unit

(** [clamp window geom] is [geom] clamped to [window]'s size hints, if any.
    Converts to [int32 rect] *)
val clamp : t -> int Oxbow_core.Rect.t -> int32 Oxbow_core.Rect.t

(** [clamp32 window geom] is [clamp] but takes an [int32 Rect.t]. *)
val clamp32 : t -> int32 Oxbow_core.Rect.t -> int32 Oxbow_core.Rect.t

(** [set_float_seed_pending window pending] sets [window]'s pending float seed
    flag to [pending].

    {b Effects:} mutates WM state *)
val set_float_seed_pending : t -> bool -> unit

(** [float window] puts [window] in the floating state.

    {b Effects:} mutates WM state *)
val float : t -> unit

(** [is_fullscreen window] is [true] if [window] is fullscreen, [false] otherwise. *)
val is_fullscreen : t -> bool

(** [fullscreen ?force window] makes [window] fullscreen.

    {b Effects:} mutates WM state *)
val fullscreen : ?force:bool -> t -> unit

(** [exit_fullscreen window] exit fullscreen and restore [window] to previous
    presentation states.

    {b Effects:} mutates WM state *)
val exit_fullscreen : t -> unit

(** [is_rendered ?fullscreen window] is [true] when all of the following are
    true:

    - [tag_visible window] is [true]
    - [window] is not covered by a fullscreen window ([window] may be occluded
      by a non-fullscreen window.)
    - [window]'s output is in the [Scrolling] layout and [window] is within
      output's scrolling viewport

    [fullscreen] states that the output holds a visible fullscreen window. When
    absent, [is_rendered] scans the focus stack. *)
val is_rendered : ?fullscreen:bool -> t -> bool

(** [queue_request window request] adds [request] to [window]'s request
    queue.

    {b Effects:} mutates WM state *)
val queue_request : t -> Request.t -> unit

(** [clear_requests window] clears [window]'s request queue.

    {b Effects:} mutates WM state *)
val clear_requests : t -> unit

(** [at_point ~x ~y lst] returns the first window in [lst] that is
    visible (per {!tag_visible}) and whose [geom] rectangle contains
    the point ([x], [y]), or [None] if none does. *)
val at_point : x:int32 -> y:int32 -> t list -> t option

(** [fake_fullscreen window] puts the [window] into the fake fullscreen state.

    {b Effects:} mutates WM state *)
val fake_fullscreen : t -> unit

(** [exit_fake_fullscreen window] exits the fake fullscreen state for [window].

    {b Effects:} mutates WM state *)
val exit_fake_fullscreen : t -> unit

(** [maximize ?restore window] informs [window] it is maximized. Saves the
    previous presentation state or [restore] if present. No-op when [window] is
    fullscreen.

    {b Effects:} mutates WM state *)
val maximize : ?restore:Presentation.Tile_or_float.t -> t -> unit

(** [unmaximize window] informs [window] it is unmaximized and restores [window]
    to its previous presentation.

    {b Effects:} mutates WM state *)
val unmaximize : t -> unit

(** [move_to window ~x ~y] moves [window] according to the extents [~x] and
    [~y].

    {b Effects:} mutates WM state *)
val move_to : t -> x:Oxbow_core.Extent.t -> y:Oxbow_core.Extent.t -> unit

(** [move_spatial window dir by] moves [window] in [dir] according to [by]
    extent.

    {b Effects:} mutates WM state *)
val move_spatial : t -> Oxbow_core.Direction.Spatial.t -> Oxbow_core.Extent.t -> unit

(** [resize_to window ~width ~height] resizes [window] according to the extents
    [~width] and [~height].

    {b Effects:} mutates WM state *)
val resize_to : t -> width:Oxbow_core.Extent.t -> height:Oxbow_core.Extent.t -> unit

(** [resize_spatial window dir by] resizes [window] in [dir] according to [by]
    extent.

    {b Effects:} mutates WM state *)
val resize_spatial : t -> Oxbow_core.Direction.Spatial.t -> Oxbow_core.Extent.t -> unit

(** [set_tags window tags] sets [window]'s tags to [tags].

    @raise Invalid_argument when [Tag.Set.is_empty tags] is [true].

    {b Effects:} mutates WM state *)
val set_tags : t -> Oxbow_core.Tag.Set.t -> unit

(** [set_consumes window v] sets the consumes chain-bit on [window] to [v].

    {b Effects:} mutates WM state *)
val set_consumes : t -> bool -> unit

(** [set_scroll_width window v] sets the scroll-width override on [window] to
    [v].

    {b Effects:} mutates WM state *)
val set_scroll_width : t -> Oxbow_core.Width_fac.t -> unit

(** [set_output window output] sets [window]'s output to [output]. Setting
    [None] records the current output's name if none has been recorded
    previously.

    {b Effects:} mutates WM state *)
val set_output : t -> Types.Output.t option -> unit

(** [set_presentation window presentation] sets [window]'s presentation to
    [presentation].

    {b Effects:} mutates WM state *)
val set_presentation : t -> Presentation.t -> unit

(** [set_is_urgent window is_urgent] sets [window]'s urgent status to
    [is_urgent].

    {b Effects:} mutates WM state *)
val set_is_urgent : t -> bool -> unit

(** [set_is_captured window is_captured] sets [window]'s captured status to
    [is_captured].

    {b Effects:} mutates WM state *)
val set_is_captured : t -> bool -> unit

(** [set_lifecycle window lifecycle] sets [window]'s lifecycle to [lifecycle].

    {b Effects:} mutates WM state *)
val set_lifecycle : t -> Lifecycle.t -> unit

(** [set_title window title] sets [window]'s title to [title].

    {b Effects:} mutates WM state *)
val set_title : t -> string option -> unit

(** [set_app_id window app_id] sets [window]'s app id to [app_id].

    {b Effects:} mutates WM state *)
val set_app_id : t -> string option -> unit

(** [set_identifier window identifier] sets [window]'s identifier to
    [identifier].

    {b Effects:} mutates WM state *)
val set_identifier : t -> string option -> unit

(** [set_unreliable_pid window unreliable_pid] sets [window]'s (unreliable)
    process id to [unreliable_pid].

    {b Effects:} mutates WM state *)
val set_unreliable_pid : t -> int32 option -> unit

(** [set_parent window ~parent] sets [window]'s parent as [parent].

    {b Effects:} mutates WM state *)
val set_parent : t -> parent:t option -> unit

(** [set_close_pending window pending] sets [window]'s pending close flag to
    [pending].

    {b Effects:} mutates WM state *)
val set_close_pending : t -> bool -> unit

(** [set_decoration_hint window hint] sets [window]'s decoration hint to [hint].

    {b Effects:} mutates WM state *)
val set_decoration_hint : t -> Decoration_hint.t option -> unit

(** [set_presentation_hint window hint] sets [window]'s presentation mode to
    [hint].

    {b Effects:} mutates WM state *)
val set_presentation_hint : t -> Wire.Presentation_mode.t option -> unit

(** [set_size_hints window size_hints] sets [window]'s size hints to
    [size_hints].

    {b Effects:} mutates WM state *)
val set_size_hints : t -> int32 option Size_hints.t -> unit

(** [set_sticky window scope] sets [window]'s sticky scope to [scope].

    {b Effects:} mutates WM state *)
val set_sticky : t -> Oxbow_core.Sticky.t -> unit

(** [add_label window label] adds [label] to [window]'s label set. No-op when
    the label is present.

    {b Effects:} mutates WM state *)
val add_label : t -> string -> unit

(** [remove_label window label] removes [label] from [window]'s label set. No-op
    when label is absent.

    {b Effects:} mutates WM state *)
val remove_label : t -> string -> unit

(** [set_swallow_role window v] updates [window]'s swallow value to [v].

    {b Effects:} mutates WM state *)
val set_swallow_role : t -> Oxbow_core.Swallow_role.t -> unit

(** [set_swallow_relation window o] updates [window]'s swallow relation to [o].

    {b Effects:} mutates WM state *)
val set_swallow_relation : t -> Swallow.Relation.t option -> unit

(** [swallow ~host ~child] sets [Swallowing host] on [child] and
    [Swallowed_by child] on [host].

    {b Effects:} mutate WM state *)
val swallow : host:t -> child:t -> unit

(** [set_is_fixed window is_fixed] sets [window]'s fixed status to [is_fixed].

    {b Effects:} mutates WM state *)
val set_is_fixed : t -> bool -> unit

(** [set_scratchpad window name] sets [window]'s scratchpad to [name].

    {b Effects:} mutates WM state *)
val set_scratchpad : t -> string option -> unit

(** [set_stashed window b] sets [window]'s scratchpad stashed status to [b].

    {b Effects:} mutates WM state *)
val set_stashed : t -> bool -> unit

(** [rehome window name] queues a request to send [window] to the output
    matching [name], when [window]'s home output matches [name]. No-op
    otherwise.

    {b Effects:} mutates WM state *)
val rehome : t -> string -> unit

(** [presentation_string window] is [window]'s current presentation as one of
    ["tiled"], ["floating"], ["maximized"], or ["fullscreen"]. *)
val presentation_string : t -> string

(** [set_informed_fullscreen window state] sets [window]'s last sent
    inform_fullscreen value to [state].

    {b Effects:} mutates WM state *)
val set_informed_fullscreen : t -> bool option -> unit

(** [set_informed_maximized window state] sets [window]'s last sent
    inform_maximized value to [state].

    {b Effects:} mutates WM state *)
val set_informed_maximized : t -> bool option -> unit

(** [set_informed_resizing window state] sets [window]'s last sent
    inform_resizing value to [state].

    {b Effects:} mutates WM state *)
val set_informed_resizing : t -> bool option -> unit

(** [set_caps window caps] sets [window]'s last sent capabilities value to
    [caps].

    {b Effects:} mutates WM state *)
val set_caps : t -> int32 option -> unit

(** [set_tiled_edges window edges] sets [window]'s last sent tiled edges value
    to [edges].

    {b Effects:} mutates WM state *)
val set_tiled_edges : t -> int32 option -> unit

(** [set_ssd window state] sets [window]'s last sent ssd value to [state].

    {b Effects:} mutates WM state *)
val set_ssd : t -> bool option -> unit

(** [set_borders window borders] sets [window]'s last sent border values to
    [borders].

    {b Effects:} mutates WM state *)
val set_borders : t -> Committed.borders option -> unit

(** [set_shown window shown] sets [window]'s last sent shown state to [shown].

    {b Effects:} mutates WM state *)
val set_shown : t -> bool option -> unit

(** [set_committed_position window position] sets [window]'s last sent position
    values to [position].

    {b Effects:} mutates WM state *)
val set_committed_position : t -> (int32 * int32) option -> unit

(** [set_clip_box window clip_box] sets [window]'s last sent clip box values to
    [clip_box].

    {b Effects:} mutates WM state *)
val set_clip_box : t -> (int32 * int32 * int32 * int32) option -> unit

(** [set_content_clip_box window clip_box] sets [window]'s last sent content
    clip box values to [content_clip_box].

    {b Effects:} mutates WM state *)
val set_content_clip_box : t -> (int32 * int32 * int32 * int32) option -> unit
