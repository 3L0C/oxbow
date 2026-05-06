open! Ocdwm_core

(** [focus_window ?force ctx seat window] focuses [window] on [seat]. No-op when
    [window] is already focused on [seat] and neither [force] nor a layer focus
    on [seat] forces a refocus. Default [force] is [false].

    {b Effects:} mutates WM state; sends River request *)
val focus_window
  :  ?force:bool
  -> Ctx.manage Ctx.t
  -> Types.Seat.t
  -> Types.Window.t
  -> unit

(** [clear ctx seat] clears any focused window on [seat].

    {b Effects:} mutates WM state; sends River request *)
val clear : Ctx.manage Ctx.t -> Types.Seat.t -> unit

(** [remove_window ctx window] removes [window] from [wm]'s management.

    {b Effects:} mutates WM state; sends River request *)
val remove_window : Ctx.manage Ctx.t -> Types.Window.t -> unit

(** [refresh_focus ctx output] clears focus if no focused window on [output], or
    returns focus to the focused window.

    {b Effects:} mutates WM state; sends River request *)
val refresh_focus : Ctx.manage Ctx.t -> Types.Output.t -> unit

(** [focused_of seat] is the window focused on [seat]'s output, or [None] if
    [seat] is not focused on any window *)
val focused_of : Types.Seat.t -> Types.Window.t option

(** [sync ctx] ensures the focus state of ocdwm is synchronized with River.

    {b Effects:} mutates WM state; sends River request *)
val sync : Ctx.manage Ctx.t -> unit

(** [focus_dir ctx seat dir] focuses the window in [dir] on [seat]'s output.

    {b Effects:} mutates WM state; sends River request *)
val focus_dir : Ctx.manage Ctx.t -> Types.Seat.t -> Direction.t -> unit

(** [focus_output ctx seat dir] focuses the output in [dir] on [seat].

    {b Effects:} mutates WM state; sends River request *)
val focus_output : Ctx.manage Ctx.t -> Types.Seat.t -> Direction.t -> unit
