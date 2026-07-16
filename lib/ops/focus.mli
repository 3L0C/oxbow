(** [layer_shell_sync wm] updates the default layer shell output to [wm]'s
    focused output, if any.

    {b Effects:} sends River request *)
val layer_shell_sync : Ocdwm_state.Wm.t -> unit

(** [set_output ctx seat output] updates the output of [seat] and sends the necessary
    layer shell requests.

    {b Effects:} mutates WM state; sends River request *)
val set_output
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_state.Output.t option
  -> unit

(** [focus_window ?force ctx seat window] focuses [window] on [seat]. No-op when
    [window] is already focused on [seat] and neither [force] nor a layer focus
    on [seat] forces a refocus. Default [force] is [false].

    {b Effects:} mutates WM state; sends River request *)
val focus_window
  :  ?force:bool
  -> Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_state.Window.t
  -> unit

(** [clear ctx seat] clears any focused window on [seat].

    {b Effects:} mutates WM state; sends River request *)
val clear : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Seat.t -> unit

(** [refresh ctx output] clears focus if no focused window on [output], or
    returns focus to the focused window.

    {b Effects:} mutates WM state; sends River request *)
val refresh : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Output.t -> unit

(** [window_logical ctx seat dir] focuses the window in logical direction [dir]
    and warps the pointer to it when configured. Returns [Error msg] when the
    focused window is fullscreen, [seat] has no output, or there is no window to
    focus.

    {b Effects:} mutates WM state; sends River request *)
val window_logical
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [window_spatial ctx seat dir] focuses the window in spatial direction [dir]
    and warps the pointer to it when configured. Returns [Error msg] when the
    focused window is fullscreen, [seat] has no output, or there is no window to
    focus.

    {b Effects:} mutates WM state; sends River request *)
val window_spatial
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Spatial.t
  -> (Yojson.Safe.t option, string) result

(** [window_query ctx seat query] focuses the first (or, when [query] cycles,
    next) window matching [query] and warps the pointer to it when configured.
    Returns [Error msg] when [query]'s regex fails to compile or no window
    matches.

    {b Effects:} mutates WM state; sends River request *)
val window_query
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Window_query.t
  -> (Yojson.Safe.t option, string) result

(** [output_logical ctx seat dir] focuses the output in logical direction [dir]
    and warps the pointer to it when configured. Returns [Error msg] when [seat]
    has no output or no other output exists.

    {b Effects:} mutates WM state; sends River request *)
val output_logical
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Logical.t
  -> (Yojson.Safe.t option, string) result

(** [output_spatial ctx seat dir] focuses the output in spatial direction [dir]
    and warps the pointer to it when configured. Return [Error msg] when [seat]
    has no output or no output lies in [dir].

    {b Effects:} mutates WM state; sends River request *)
val output_spatial
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> Ocdwm_core.Direction.Spatial.t
  -> (Yojson.Safe.t option, string) result

(** [output_name ctx seat name] focuses the output named [name] and warps the
    pointer to it when configured. Returns [Error msg] when no output is named
    [name].

    {b Effects:} mutates WM state; sends River request *)
val output_name
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> string
  -> (Yojson.Safe.t option, string) result

(** [remove_window ctx window] removes [window] from [wm]'s management.

    {b Effects:} mutates WM state; sends River request *)
val remove_window
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Window.t
  -> unit

(** [wm_sync ctx] ensures the focus state of ocdwm is synchronized with River.

    {b Effects:} mutates WM state; sends River request *)
val wm_sync : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> unit

(** [seat_sync ctx seat] refreshes the layer focus and cursor target [seat].

    {b Effects:} mutates WM state; sends River request *)
val seat_sync : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Seat.t -> unit

(** [apply_request ctx seat] handles the focus request on [seat].

    {b Effects:} mutates WM state; sends River request *)
val apply_request : Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t -> Ocdwm_state.Seat.t -> unit

(** [apply_interaction ctx seat] handles the interaction request on [seat].

    {b Effects:} mutates WM state; sends River request *)
val apply_interaction
  :  Ocdwm_state.Ctx.manage Ocdwm_state.Ctx.t
  -> Ocdwm_state.Seat.t
  -> unit
