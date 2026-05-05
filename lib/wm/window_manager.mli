open Types

type t = Types.Window_manager_t.t

(** [set_focused_output wm output] sets [output] as the focused output for the
    window manager.

    {b Effects:} mutates WM state *)
val set_focused_output : t -> Output_t.t option -> unit

(** [focus_output ctx output] sets [output] as the focused output and syncs with
    River.

   {b Effects:} mutates WM state; sends River request *)
val focus_output : Ctx.manage Ctx.t -> Types.Output_t.t option -> unit

(** [sync ctx] syncs ocdwm and River state.

    {b Effects:} mutates WM state; sends River request *)
val sync : Ctx.manage Ctx.t -> unit
