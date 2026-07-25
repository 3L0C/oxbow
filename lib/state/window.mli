include module type of Types.Window

(** [create wm output river_window] is a unique window. *)
val create
  :  Types.Output.t option
  -> Ocdwm_core.Width_fac.t
  -> River.V.Window_management.t River.Window_management.River_window_v1.t
  -> t

(** [destroy window] destroys the Wayland objects backing [window].
    No-op (with a warning) when [window]'s lifecycle isn't [Closing].

    {b Effects:} sends River request *)
val destroy : t -> unit

(** [set_position ctx window ~x ~y] positions [window] at ([x], [y]).

    {b Effects:} mutates WM state; sends River request *)
val set_position : 'p Ctx.t -> t -> x:int32 -> y:int32 -> unit

(** [propose_dimensions ctx window ~width ~height] proposes content dimensions
    to [window]. Skips the request when it equals the last proposal.

    {b Effects:} mutates WM state; sends River request *)
val propose_dimensions : Ctx.manage Ctx.t -> t -> width:int32 -> height:int32 -> unit

(** [set_geom ctx window geom] updates [window]'s geometry to [geom] and
    positions/resizes window to match the new state.

    {b Effects:} mutates WM state; sends River request *)
val set_geom : Ctx.manage Ctx.t -> t -> int32 Ocdwm_core.Rect.t -> unit

(** [on_tags window ~tags] is true when [window]'s tags intersect with [tags]. *)
val on_tags : t -> tags:Ocdwm_core.Tag.Set.t -> bool

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
val clamp : t -> int Ocdwm_core.Rect.t -> int32 Ocdwm_core.Rect.t

(** [restore_or_seed_float ctx window] positions and resizes [window] according
    to its last remembered float value. If no such value is stored, [window] is
    centered and sized to 50% of the usable height and width of its output.
    Clamps to [window]'s size hints.

    {b Effects:} mutates WM state; sends River request *)
val restore_or_seed_float : Ctx.manage Ctx.t -> t -> unit

(** [float ctx window] puts [window] in the floating state.

    {b Effects:} mutates WM state; sends River request *)
val float : Ctx.manage Ctx.t -> t -> unit

(** [is_fullscreen window] is [true] if [window] is fullscreen, [false] otherwise. *)
val is_fullscreen : t -> bool

(** [fullscreen ?force ctx window] makes [window] fullscreen.

    {b Effects:} mutates WM state; sends River request *)
val fullscreen : ?force:bool -> Ctx.manage Ctx.t -> t -> unit

(** [exit_fullscreen ctx window] exit fullscreen and restore [window] to
    previous presentation states.

    {b Effects:} mutates WM state; sends River request *)
val exit_fullscreen : Ctx.manage Ctx.t -> t -> unit

(** [is_rendered window] is [true] when all of the following are true:
    - [tag_visible window] is [true]
    - [window] is not covered by a fullscreen window ([window] may be occluded
      by a non-fullscreen window.)
    - [window]'s output is in the [Scrolling] layout and [window] is within
      output's scrolling viewport *)
val is_rendered : t -> bool

(** [sync ctx window] ensures [window] is shown or hidden based on window manager
    state.

    {b Effects:} mutates WM state; sends River request *)
val sync : Ctx.manage Ctx.t -> t -> unit

(** [queue_request wm window request] adds [request] to [window]'s request
    queue.

    {b Effects:} mutates WM state; marks [wm] dirty *)
val queue_request : Types.Wm.t -> t -> Request.t -> unit

(** [clear_requests window] clears [window]'s request queue.

    {b Effects:} mutates WM state *)
val clear_requests : t -> unit

(** [fit_to_output ctx window] repositions and resizes [window] to fit
    on the output it is displayed on.

    {b Effects:} mutates WM state; sends River request *)
val fit_to_output : Ctx.manage Ctx.t -> t -> unit

(** [at_point ~x ~y lst] returns the first window in [lst] that is
    visible (per {!tag_visible}) and whose [geom] rectangle contains
    the point ([x], [y]), or [None] if none does. *)
val at_point : x:int32 -> y:int32 -> t list -> t option

(** [fake_fullscreen ctx window] puts the [window] into the fake fullscreen
    state.

    {b Effects:} mutates WM state; sends River request *)
val fake_fullscreen : Ctx.manage Ctx.t -> t -> unit

(** [exit_fake_fullscreen ctx window] exits the fake fullscreen state for
    [window].

    {b Effects:} mutates WM state; sends River request *)
val exit_fake_fullscreen : Ctx.manage Ctx.t -> t -> unit

(** [maximize ?restore ctx window] informs [window] it is maximized. Saves the
    previous presentation state or [restore] if present. No-op when [window] is
    fullscreen.

    {b Effects:} mutates WM state; sends River request *)
val maximize : ?restore:Presentation.Tile_or_float.t -> Ctx.manage Ctx.t -> t -> unit

(** [unmaximize ctx window] informs [window] it is unmaximized and restores
    [window] to its previous presentation.

    {b Effects:} mutates WM state; sends River request *)
val unmaximize : Ctx.manage Ctx.t -> t -> unit

(** [move_to ctx window ~x ~y] moves [window] according to the extents [~x] and [~y].

    {b Effects:} mutates WM state; sends River request *)
val move_to
  :  Ctx.manage Ctx.t
  -> t
  -> x:Ocdwm_core.Extent.t
  -> y:Ocdwm_core.Extent.t
  -> unit

(** [move_spatial ctx window dir by] moves [window] in [dir] according to [by]
    extent.

    {b Effects:} mutates WM state; sends River request *)
val move_spatial
  :  Ctx.manage Ctx.t
  -> t
  -> Ocdwm_core.Direction.Spatial.t
  -> Ocdwm_core.Extent.t
  -> unit

(** [resize_to ctx window ~width ~height] resizes [window] according to the
    extents [~width] and [~height].

    {b Effects:} mutates WM state; sends River request *)
val resize_to
  :  Ctx.manage Ctx.t
  -> t
  -> width:Ocdwm_core.Extent.t
  -> height:Ocdwm_core.Extent.t
  -> unit

(** [resize_spatial ctx window dir by] resizes [window] in [dir] according to
    [by] extent.

    {b Effects:} mutates WM state; sends River request *)
val resize_spatial
  :  Ctx.manage Ctx.t
  -> t
  -> Ocdwm_core.Direction.Spatial.t
  -> Ocdwm_core.Extent.t
  -> unit

(** [set_tags window tags] sets [window]'s tags to [tags].

    @raise Invalid_argument when [Tag.Set.is_empty tags] is [true].

    {b Effects:} mutates WM state; marks dirty *)
val set_tags : t -> Ocdwm_core.Tag.Set.t -> unit

(** [set_consumes window v] sets the consumes chain-bit and marks [window]'s
    output dirty on change.

    {b Effects:} mutates WM state; marks dirty *)
val set_consumes : t -> bool -> unit

(** [set_scroll_width window v] sets the scroll-width override and marks
    [window]'s output dirty on change.

    {b Effects:} mutates WM state; marks dirty *)
val set_scroll_width : t -> Ocdwm_core.Width_fac.t -> unit

(** [set_output window output] sets [window]'s output to [output]. Setting
    [None] records the current output's name if none has been recorded
    previously.

    {b Effects:} mutates WM state; marks dirty *)
val set_output : t -> Types.Output.t option -> unit

(** [set_presentation window presentation] sets [window]'s presentation to
    [presentation].

    {b Effects:} mutates WM state; marks dirty *)
val set_presentation : t -> Presentation.t -> unit

(** [set_is_urgent window is_urgent] sets [window]'s urgent status to
    [is_urgent].

    {b Effects:} mutates WM state; marks dirty *)
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

    {b Effects:} mutates WM state; marks dirty *)
val set_parent : t -> parent:t option -> unit

(** [set_float_seed_pending window pending] sets [window]'s pending float seed
    flag to [pending].

    {b Effects:} mutates WM state *)
val set_float_seed_pending : t -> bool -> unit

(** [set_decoration_hint window decoration_hint] sets [window]'s decoration hint
    to [decoration_hint].

    {b Effects:} mutates WM state *)
val set_decoration_hint : t -> Decoration_hint.t option -> unit

(** [set_presentation_hint window presentation_hint] sets [window]'s
    presentation hint to [presentation_hint].

    {b Effects:} mutates WM state *)
val set_presentation_hint
  :  t
  -> River.Window_management.River_output_v1.Presentation_mode.t option
  -> unit

(** [set_size_hints window size_hints] sets [window]'s size hints to
    [size_hints].

    {b Effects:} mutates WM state *)
val set_size_hints : t -> int32 Size_hints.t -> unit

(** [set_is_fixed window is_fixed] sets [window]'s fixed status to [is_fixed].

    {b Effects:} mutates WM state *)
val set_is_fixed : t -> bool -> unit

(** [set_is_hidden window is_hidden] sets [window]'s hidden status to
    [is_hidden].

    {b Effects:} mutates WM state *)
val set_is_hidden : t -> bool -> unit

(** [rehome wm window name] queues a request to send [window] to the output
    matching [name], when [window]'s home output matches [name]. No-op
    otherwise.

    {b Effects:} mutates WM state; marks dirty *)
val rehome : Types.Wm.t -> t -> string -> unit

(** [presentation_string window] is [window]'s current presentation as one of
    ["tiled"], ["floating"], ["maximized"], or ["fullscreen"]. *)
val presentation_string : t -> string
