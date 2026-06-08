type t = Types.Window.t

(** [create wm river_window] is a unique window. *)
val create
  :  Types.Window_manager.t
  -> River.V.Window_management.t River.Window_management.River_window_v1.t
  -> t

(** [destroy window] destroys the Wayland objects backing [window].
    No-op unless [window.state = W_closing].

    {b Effects:} sends River request *)
val destroy : t -> unit

(** [set_position ctx window ~x ~y] positions [window] at ([x], [y]).

    {b Effects:} mutates WM state; sends River request *)
val set_position : 'p Ctx.t -> t -> x:int32 -> y:int32 -> unit

(** [set_geom ctx window geom] updates [window.geom] to [geom] and positions/resizes
    window to match the new state.

    {b Effects:} mutates WM state; sends River request *)
val set_geom : Ctx.manage Ctx.t -> t -> int32 Ocdwm_core.Rect.t -> unit

(** [tag_visible window] is [true] if [window] is assigned to an output whose
    selected tags intersect [window]'s. Is [false] otherwise. *)
val tag_visible : t -> bool

(** [is_tiled window] is [true] when [window] is tiled. *)
val is_tiled : t -> bool

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

(** [toggle_floating ctx window] floats [window] if tiled and tiles if floating,
    when [window] is not [None].

    {b Effects:} mutates WM state; sends River request *)
val toggle_floating : Ctx.manage Ctx.t -> t option -> unit

(** [is_fullscreen window] is [true] if [window] is fullscreen, [false] otherwise. *)
val is_fullscreen : t -> bool

(** [fullscreen ?force ctx window] makes [window] fullscreen.

    {b Effects:} mutates WM state; sends River request *)
val fullscreen : ?force:bool -> Ctx.manage Ctx.t -> t -> unit

(** [exit_fullscreen ctx window] exit fullscreen and restore [window] to
    previous presentation states.

    {b Effects:} mutates WM state; sends River request *)
val exit_fullscreen : Ctx.manage Ctx.t -> t -> unit

(** [is_rendered window] is [true] when [tag_visible window] is [true] and
    [window] is not covered by a fullscreen window. [window] may be occluded by
    a non-fullscreen window. *)
val is_rendered : t -> bool

(** [sync ctx window] ensures [window] is shown or hidden based on window manager
    state.

    {b Effects:} mutates WM state; sends River request *)
val sync : 'p Ctx.t -> t -> unit

(** [queue_request window request] adds [request] to [window]'s request queue.

    {b Effects:} mutates WM state *)
val queue_request : t -> Types.Window_request.t -> unit

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
  -> Ocdwm_core.Spatial_direction.t
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
  -> Ocdwm_core.Spatial_direction.t
  -> Ocdwm_core.Extent.t
  -> unit
