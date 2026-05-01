module Rwm =
  Ocdwm_protocol.River_window_management_v1_client

(** [create wm river_window] is a unique window. *)
val create :
   Types.window_manager ->
  [ `V4 ] Rwm.River_window_v1.t ->
  Types.window

(** [destroy window] destroys the Wayland objects backing [window].
    No-op unless [window.state = W_closing].

    {b Effects:} sends River request *)
val destroy : Types.window -> unit

(** [set_position wm window ~x ~y] positions [window] at ([x], [y]).
    No-op when [wm.phase = P_idle].

    {b Effects:} mutates WM state; sends River request

    {b Timing:} manage or render cycle *)
val set_position :
   Types.window_manager ->
  Types.window ->
  x:int32 ->
  y:int32 ->
  unit

(** [set_geom wm window geom] updates [window.geom] to [geom] and positions/resizes
    window to match the new state.
    No-op when [wm.phase <> P_manage].

    {b Effects:} mutates WM state; sends River request

    {b Timing:} manage cycle *)
val set_geom :
   Types.window_manager ->
  Types.window ->
  int32 Ocdwm_core.Types.rect ->
  unit

(** [tag_visible window] is [true] if [window] is assigned to an output whose
    selected tags intersect [window]'s. Is [false] otherwise. *)
val tag_visible : Types.window -> bool

(** [is_tiled window] is [true] when [window] is tiled. *)
val is_tiled : Types.window -> bool

(** [remember_float window] saves [window]'s current geometry to restore when
    [window] transitions to the floating state.

    {b Effects:} mutates WM state *)
val remember_float : Types.window -> unit

(** [tile window] puts [window] into the tiled state.

    {b Effects:} mutates WM state *)
val tile : Types.window -> unit

(** [clamp window geom] is [geom] clamped to [window]'s size hints, if any.
    Converts to [int32 rect] *)
val clamp :
   Types.window ->
  int Ocdwm_core.Types.rect ->
  int32 Ocdwm_core.Types.rect

(** [restore_or_seed_float wm window] positions and resizes [window] according
    to its last remembered float value. If no such value is stored, [window] is
    centered and sized to 50% of the usable height and width of its output.
    Clamps to [window]'s size hints.

    {b Effects:} mutates WM state

    {b Timing:} manage cycle *)
val restore_or_seed_float :
   Types.window_manager ->
  Types.window ->
  unit

(** [toggle_floating wm window] floats [window] if tiled and tiles if floating,
    when [window] is not [None].

    {b Effects:} mutates WM state; sends River request

    {b Timing:} manage cycle *)
val toggle_floating :
   Types.window_manager ->
  Types.window option ->
  unit

(** [is_fullscreen window] is [true] if [window] is fullscreen, [false] otherwise. *)
val is_fullscreen : Types.window -> bool

(** [fullscreen wm window restore] makes [window] fullscreen, and stores
    [restore].

    {b Effects:} mutates WM state; sends River request

    {b Timing:} manage cycle *)
val fullscreen :
   Types.window_manager ->
  Types.window ->
  [ `Tiled | `Floating ] ->
  unit

(** [exit_fullscreen wm window presentation] transitions [window] to
    [presentation] if [window] is fullscreen.

    {b Effects:} mutates WM state; sends River request

    {b Timing:} manage cycle *)
val exit_fullscreen :
   Types.window_manager ->
  Types.window ->
  [ `Tiled | `Floating ] ->
  unit

(** [is_rendered window] is [true] when [tag_visible window] is [true] and
    [window] is not covered by a fullscreen window. [window] may be occluded by
    a non-fullscreen window. *)
val is_rendered : Types.window -> bool

(** [sync wm window] ensures [window] is shown or hidden based on window manager
    state.

    {b Effects:} mutates WM state; sends River request

    {b Timing:} manage or render cycle *)
val sync : Types.window_manager -> Types.window -> unit

(** [queue_request window request] adds [request] to [window]'s request queue.

    {b Effects:} mutates WM state *)
val queue_request :
   Types.window ->
  Types.window_request ->
  unit

(** [clear_requests window] clears [window]'s request queue.

    {b Effects:} mutates WM state *)
val clear_requests : Types.window -> unit

(** [fit_to_output wm window] repositions and resizes [window] to fit
    on the output it is displayed on.

    {b Effects:} mutates WM state; sends River request

    {b Timing:} manage or render cycle *)
val fit_to_output :
   Types.window_manager ->
  Types.window ->
  unit

(** [at_point ~x ~y lst] returns the first window in [lst] that is
    visible (per {!tag_visible}) and whose [geom] rectangle contains
    the point ([x], [y]), or [None] if none does. *)
val at_point :
   x:int32 ->
  y:int32 ->
  Types.window list ->
  Types.window option
