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

(** [tag_visible window] is [true] if [window]'s output is in overview mode or
    [window]'s tags intersect its output's selected tags. Is [false] otherwise. *)
val tag_visible : t -> bool

(** [is_tiled window] is [true] when [window] is tiled. *)
val is_tiled : t -> bool

(** [is_tiled_on_tag window] is [tag_visible window && is_tiled window] *)
val is_tiled_on_tag : t -> bool

(** [remember_float window] saves [window]'s current geometry to restore when
    [window] transitions to the floating state.

    {b Effects:} mutates WM state *)
val remember_float : t -> unit

(** [tile window] puts [window] into the tiled state.

    {b Effects:} mutates WM state *)
val tile : t -> unit

(** [clamp window geom] is [geom] clamped to [window]'s size hints, if any.
    Converts to [int32 rect] *)
val clamp : t -> int Oxbow_core.Rect.t -> int32 Oxbow_core.Rect.t

(** [set_float_seed_pending window pending] sets [window]'s pending float seed
    flag to [pending].

    {b Effects:} mutates WM state *)
val set_float_seed_pending : t -> bool -> unit

(** [restore_or_seed_float window] positions and resizes [window] according
    to its last remembered float value. If no such value is stored, [window] is
    centered and sized to 50% of the usable height and width of its output.
    Clamps to [window]'s size hints.

    {b Effects:} mutates WM state *)
val restore_or_seed_float : t -> unit

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

(** [is_rendered window] is [true] when all of the following are true:
    - [tag_visible window] is [true]
    - [window] is not covered by a fullscreen window ([window] may be occluded
      by a non-fullscreen window.)
    - [window]'s output is in the [Scrolling] layout and [window] is within
      output's scrolling viewport *)
val is_rendered : t -> bool

(** [queue_request window request] adds [request] to [window]'s request
    queue.

    {b Effects:} mutates WM state *)
val queue_request : t -> Request.t -> unit

(** [clear_requests window] clears [window]'s request queue.

    {b Effects:} mutates WM state *)
val clear_requests : t -> unit

(** [fit_to_output window] repositions and resizes [window] to fit on the output
    it is displayed on.

    {b Effects:} mutates WM state *)
val fit_to_output : t -> unit

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
val set_size_hints : t -> int32 Size_hints.t -> unit

(** [set_is_fixed window is_fixed] sets [window]'s fixed status to [is_fixed].

    {b Effects:} mutates WM state *)
val set_is_fixed : t -> bool -> unit

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
val set_borders : t -> (int32 * int32 * int32 * int32 * int32 * int32) option -> unit
