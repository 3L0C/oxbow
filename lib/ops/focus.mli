(** [layer_shell_sync wm] updates the default layer shell output to [wm]'s
    focused output, if any. *)
val layer_shell_sync : Oxbow_state.Wm.t -> unit

(** [set_output wm seat output] updates the output of [seat] and sends the necessary
    layer shell requests.

    {b Effects:} mutates WM state *)
val set_output
  :  Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_state.Output.t option
  -> unit

(** [focus_window ?force ?warp wm seat window] focuses [window] on [seat].
    No-op when [window] is already focused on [seat] and neither [force] nor a
    layer focus on [seat] forces a refocus. Default [force] is [false]. When
    [warp] is present, it becomes [seat]'s warp request.  When [warp] is absent,
    the warp request does not change.

    {b Effects:} mutates WM state *)
val focus_window
  :  ?force:bool
  -> ?warp:Oxbow_state.Seat.Warp_request.t
  -> Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_state.Window.t
  -> unit

(** [refresh wm output] clears focus if no focused window on [output], or
    returns focus to the focused window.

    {b Effects:} mutates WM state *)
val refresh : Oxbow_state.Wm.t -> Oxbow_state.Output.t -> unit

(** [window_logical ?warp wm seat dir] focuses the window in logical direction [dir]
    The payload [warp] overrides the warp on focus configuration. Is [Error msg]
    when the focused window is fullscreen, [seat] has no output, or there is no
    window to focus.

    {b Effects:} mutates WM state *)
val window_logical
  :  ?warp:bool
  -> Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [window_spatial ?warp wm seat dir] focuses the window in spatial direction [dir]
    The payload [warp] overrides the warp on focus configuration. Is [Error msg]
    when the focused window is fullscreen, [seat] has no output, or there is no
    window to focus.

    {b Effects:} mutates WM state *)
val window_spatial
  :  ?warp:bool
  -> Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Direction.Spatial.t
  -> (Yojson.Safe.t option, string) result

(** [window_match ?warp ~cycle wm seat wmatch] focuses the first (or, next when
    [cycle] is [true]) window matching [wmatch]. The payload [warp] overrides the
    warp on focus configuration. Is [Error msg] when [wmatch]'s regex fails to
    compile or no window matches.

    {b Effects:} mutates WM state *)
val window_match
  :  ?warp:bool
  -> cycle:bool
  -> Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Window_match.t
  -> (Yojson.Safe.t option, string) result

(** [focus_output ?warp wm seat output] focuses [output] on [seat].
    No-op when [outupt] is already focused on [seat]. When [warp] is present, it
    becomes [seat]'s warp request. When [warp] is absent, the warp request does
    not change.

    {b Effects:} mutates WM state *)
val focus_output
  :  ?warp:bool
  -> Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_state.Output.t
  -> unit

(** [output_logical ?warp wm seat dir] focuses the output in logical direction
    [dir]. The payload [warp] overrides the warp on focus configuration. Is
    [Error msg] when [seat] has no output or no other output exists.

    {b Effects:} mutates WM state *)
val output_logical
  :  ?warp:bool
  -> Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [output_spatial ?warp wm seat dir] focuses the output in spatial direction [dir].
    The payload [warp] overrides the warp on focus configuration. Is [Error msg]
    when [seat] has no output or no output lies in [dir].

    {b Effects:} mutates WM state *)
val output_spatial
  :  ?warp:bool
  -> Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> Oxbow_core.Direction.Spatial.t
  -> (Yojson.Safe.t option, string) result

(** [output_name ?warp wm seat name] focuses the output named [name]. The
    payload [warp] overrides the warp on focus configuration. Is [Error msg]
    when no output is named [name].

    {b Effects:} mutates WM state *)
val output_name
  :  ?warp:bool
  -> Oxbow_state.Wm.t
  -> Oxbow_state.Seat.t
  -> string
  -> (Yojson.Safe.t option, string) result

(** [remove_window wm window] removes [window] from [wm]'s management.

    {b Effects:} mutates WM state *)
val remove_window : Oxbow_state.Wm.t -> Oxbow_state.Window.t -> unit

(** [wm_sync wm] synchronizes River and oxbow focus state.

    {b Effects:} mutates WM state *)
val wm_sync : Oxbow_state.Wm.t -> unit

(** [seat_sync wm seat] refreshes the layer focus and cursor target [seat].

    {b Effects:} mutates WM state *)
val seat_sync : Oxbow_state.Wm.t -> Oxbow_state.Seat.t -> unit

(** [apply_request wm seat] handles the focus request on [seat].

    {b Effects:} mutates WM state *)
val apply_request : Oxbow_state.Wm.t -> Oxbow_state.Seat.t -> unit

(** [apply_interaction wm seat] handles the interaction request on [seat].

    {b Effects:} mutates WM state *)
val apply_interaction : Oxbow_state.Wm.t -> Oxbow_state.Seat.t -> unit
