include module type of Types.Config

(** [create_tag_data ()] is the default [Data.t] configuration. *)
val create_tag_data : unit -> Data.t

(** [default ()] is the default config. *)
val default : unit -> t

(** [set_focus_follows_pointer wm focus_follows_pointer] sets [wm]'s "focus
    follows pointer" flag to [focus_follows_pointer].

    {b Effects:} mutates WM state *)
val set_focus_follows_pointer : Types.Wm.t -> bool -> unit

(** [set_warp_on_focus wm warp_on_focus] sets [wm]'s "warp on focus" flag to
    [warp_on_focus].

    {b Effects:} mutates WM state *)
val set_warp_on_focus : Types.Wm.t -> bool -> unit

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
  -> Ocdwm_core.Border_target.t
  -> Ocdwm_core.Color.t
  -> unit

(** [set_default_width td ~delta] applies [delta] to the default column width of
    [td].

    {b Effects:} mutates [td] *)
val set_default_width : Data.t -> delta:float Ocdwm_core.Delta.t -> unit

(** [copy_tag_data td] is a copy of [td] that shares no mutable record with
    [td]. *)
val copy_tag_data : Data.t -> Data.t

(** [add_window_rule wm rule] adds window rule defined by [rule] to [wm]'s
    configuration.

    {b Effects:} mutates WM state *)
val add_window_rule : Types.Wm.t -> Ocdwm_core.Window_rule.t -> unit

(** [remove_window_rule wm index] removes the window rule at [index] from [wm]'s
    configuration.

    {b Effects:} mutates WM state *)
val remove_window_rule : Types.Wm.t -> int -> unit

(** [replace_window_rule wm rule] replaces any window rule in [wm] with the same
    pattern as [rule].

    {b Effects:} mutates WM state *)
val replace_window_rule : Types.Wm.t -> Ocdwm_core.Window_rule.t -> unit

(** [add_input_rule wm rule] adds input rule defined by [rule] to [wm]'s
    configuration.

    {b Effects:} mutates WM state *)
val add_input_rule : Types.Wm.t -> Ocdwm_core.Input_rule.t -> unit

(** [remove_input_rule wm index] removes the input rule at [index] from [wm]'s
    configuration.

    {b Effects:} mutates WM state *)
val remove_input_rule : Types.Wm.t -> int -> unit

(** [replace_input_rule wm rule] replaces any input rule in [wm] that matches
    [rule].

    {b Effects:} mutates WM state *)
val replace_input_rule : Types.Wm.t -> Ocdwm_core.Input_rule.t -> unit

(** [declare_mode wm name] appends [name] to the declared modes.

    {b Effects:} mutates WM state *)
val declare_mode : Types.Wm.t -> string -> unit
