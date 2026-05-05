module Rwm = Ocdwm_protocol.River_window_management_v1_client
open Ocdwm_core.Types
open Types

type t = Types.Window_t.t

(** [create wm river_window] is a unique window. *)
val create : Window_manager.t -> [ `V4 ] Rwm.River_window_v1.t -> t

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
val set_geom : Ctx.manage Ctx.t -> t -> int32 Rect.t -> unit

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
val clamp : t -> int Rect.t -> int32 Rect.t

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

(** [fullscreen ctx window restore] makes [window] fullscreen, and stores
    [restore].

    {b Effects:} mutates WM state; sends River request *)
val fullscreen : Ctx.manage Ctx.t -> t -> [ `Tiled | `Floating ] -> unit

(** [exit_fullscreen ctx window presentation] transitions [window] to
    [presentation] if [window] is fullscreen.

    {b Effects:} mutates WM state; sends River request *)
val exit_fullscreen : Ctx.manage Ctx.t -> t -> [ `Tiled | `Floating ] -> unit

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
val queue_request : t -> Window_request.t -> unit

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
