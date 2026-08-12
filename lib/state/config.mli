include module type of Types.Config

(** [create_tag_data ()] is the default [Data.t] configuration. *)
val create_tag_data : unit -> Data.t

(** [default ()] is the default config. *)
val default : unit -> t

(** [set_focus_follows_pointer wm policy] sets the focus follows pointer policy
    for [wm].

    {b Effects:} mutates WM state *)
val set_focus_follows_pointer : Types.Wm.t -> Oxbow_core.Focus_follows_policy.t -> unit

(** [set_warp_on_focus wm warp_on_focus] sets [wm]'s "warp on focus" flag to
    [warp_on_focus].

    {b Effects:} mutates WM state *)
val set_warp_on_focus : Types.Wm.t -> bool -> unit

(** [set_drag_retile wm b] sets [wm]'s drag retile flag to [b].

    {b Effects:} mutates WM state *)
val set_drag_retile : Types.Wm.t -> bool -> unit

(** [set_border_width wm width] sets [wm]'s border width to [width].
    Is [Error msg] when [width] is negative.

    {b Effects:} mutates WM state *)
val set_border_width : Types.Wm.t -> int32 -> (Yojson.Safe.t option, string) result

(** [set_cursor_theme wm cursor_theme] sets [wm]'s cursor theme to
    [cursor_theme].

    {b Effects:} mutates WM state *)
val set_cursor_theme : Types.Wm.t -> (string * int32) option -> unit

(** [set_key_repeat wm ~rate ~delay] sets the key repeat [rate] and [delay].

    {b Effects:} mutates WM state *)
val set_key_repeat : Types.Wm.t -> rate:int -> delay:int -> unit

(** [set_border_color wm border color] sets the target [border] type to [color].

    {b Effects:} mutates WM state *)
val set_border_color
  :  Types.Wm.t
  -> Oxbow_core.Border_target.t
  -> Oxbow_core.Color.t
  -> unit

(** [set_default_width td ~delta] applies [delta] to the default column width of
    [td].

    {b Effects:} mutates WM state *)
val set_default_width : Data.t -> delta:float Oxbow_core.Delta.t -> unit

(** [set_spawn_position wm position] sets [position] as the spawn position of
    new windows for [wm].

    {b Effects:} mutates WM state *)
val set_spawn_position : Types.Wm.t -> Oxbow_core.Spawn_position.t -> unit

(** [set_spawn_focus wm b] sets [wm]'s focus on spawn to [b].

    {b Effects:} mutates WM state *)
val set_spawn_focus : Types.Wm.t -> bool -> unit

(** [copy_tag_data td] is a copy of [td] that shares no mutable record with
    [td]. *)
val copy_tag_data : Data.t -> Data.t

(** [add_window_rule wm rule] adds window rule defined by [rule] to [wm]'s
    configuration.

    {b Effects:} mutates WM state *)
val add_window_rule : Types.Wm.t -> Oxbow_core.Window_rule.t -> unit

(** [remove_window_rule wm index] removes the window rule at [index] from [wm]'s
    configuration.

    {b Effects:} mutates WM state *)
val remove_window_rule : Types.Wm.t -> int -> unit

(** [replace_window_rule wm rule] replaces any window rule in [wm] with the same
    pattern as [rule].

    {b Effects:} mutates WM state *)
val replace_window_rule : Types.Wm.t -> Oxbow_core.Window_rule.t -> unit

(** [add_input_rule wm rule] adds input rule defined by [rule] to [wm]'s
    configuration.

    {b Effects:} mutates WM state *)
val add_input_rule : Types.Wm.t -> Oxbow_core.Input_rule.t -> unit

(** [remove_input_rule wm index] removes the input rule at [index] from [wm]'s
    configuration.

    {b Effects:} mutates WM state *)
val remove_input_rule : Types.Wm.t -> int -> unit

(** [replace_input_rule wm rule] replaces any input rule in [wm] that matches
    [rule].

    {b Effects:} mutates WM state *)
val replace_input_rule : Types.Wm.t -> Oxbow_core.Input_rule.t -> unit

(** [declare_mode wm name] appends [name] to the declared modes.

    {b Effects:} mutates WM state *)
val declare_mode : Types.Wm.t -> Oxbow_core.Mode.t -> unit
