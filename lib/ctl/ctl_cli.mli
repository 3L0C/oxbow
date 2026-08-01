(** [seat] is the [--seat NAME] common option: [NAME] receives the request in
    place of the primary seat. *)
val seat : string option Cmdliner.Term.t

(** [socket] is the [--socket PATH] common option: [PATH] overrides the resolved
    ocdwm socket path. *)
val socket : string option Cmdliner.Term.t

(** [logical_targets] is each logical direction keyed by its name. *)
val logical_targets : (string * Ocdwm_core.Direction.Logical.t) list

(** [spatial_targets] is each spatial direction keyed by its name. *)
val spatial_targets : (string * Ocdwm_core.Direction.Spatial.t) list

(** [direction_targets] is [logical_targets] and [spatial_targets] combined. *)
val direction_targets : (string * Ocdwm_core.Direction.t) list

(** [int_delta] is the required leading [DELTA] positional: an absolute value
    ([6]) or a signed offset ([-2]). *)
val int_delta : int Ocdwm_core.Delta.t Cmdliner.Term.t

(** [float_delta] is the required leading [DELTA] positional: an absolute value
    ([0.55]) or a signed offset ([-0.05]). *)
val float_delta : float Ocdwm_core.Delta.t Cmdliner.Term.t

(** [tag_arg_at index] is the required leading [TAGS] positional at [index]:
    indices, ranges, a bitmask, or the literal [occupied]. *)
val tag_arg_at : int -> Ocdwm_core.Tag.Arg.t Cmdliner.Term.t

(** [tag_arg] is the required leading [TAGS] positional: indices, ranges, a
    bitmask, or the literal [occupied]. *)
val tag_arg : Ocdwm_core.Tag.Arg.t Cmdliner.Term.t

(** [tag_set] is the required leading [TAGS] positional: indices, ranges, or a
    bitmask. *)
val tag_set : Ocdwm_core.Tag.Set.t Cmdliner.Term.t

(** [occupied_flag] is the [--occupied] flag used to restrict tag operations. *)
val occupied_flag : bool Cmdliner.Term.t

(** [policy_flag] is the [--take] flag as a tag policy, [Keep] when absent. *)
val policy_flag : Ocdwm_core.Tag.Policy.t Cmdliner.Term.t

(** [follow_flag] is the [--follow] flag, used to signal focus moves with the
    manipulated object. *)
val follow_flag : bool Cmdliner.Term.t

(** [swap_target] is the swap destination: the optional [OUTPUT] positional
    pair, or [--ring OUTPUTS] with [--rev]. The term rejects [--ring] with a
    positional, and [--rev] without [--ring]. *)
val swap_target : Ocdwm_ipc.Command.Output.Swap.Target.t Cmdliner.Term.t

(** [bind_swap_target] is [swap_target] for bind terms so the positionals sit
    left of the [to KEYBIND] suffix. *)
val bind_swap_target : Ocdwm_ipc.Command.Output.Swap.Target.t Cmdliner.Term.t

(** [app_id_flag] is the [--app-id REGEX] option. *)
val app_id_flag : string option Cmdliner.Term.t

(** [title_flag] is the [--title REGEX] option. *)
val title_flag : string option Cmdliner.Term.t

(** [identifier_flag] is the [--identifier REGEX] option. *)
val identifier_flag : string option Cmdliner.Term.t

(** [case_flag] is the [-i] / [--ignore-case] flag for a window match; regex
    patterns match case-insensitively when set. *)
val case_flag : Ocdwm_core.Pattern.Case.t Cmdliner.Term.t

(** [device_name_arg] is the [--name REGEX] flag for a PCRE regex on the input
    device name. *)
val device_name_arg : string option Cmdliner.Term.t

(** [invert_flag] is the [--invert] flag for a window match. The match selects
    the windows that do not match when the flag is set. *)
val invert_flag : bool Cmdliner.Term.t

(** [output_name_arg] is the required leading [OUTPUT_NAME] positional. *)
val output_name_arg : string Cmdliner.Term.t

(** [output_flag] is the optional [--output NAME] filter flag. *)
val output_flag : string option Cmdliner.Term.t

(** [extent_conv] converts an extent argument. *)
val extent_conv : Ocdwm_core.Extent.t Cmdliner.Arg.conv

(** [keybind_arg] is the required trailing [KEYBIND] positional: modifiers,
    keysym, and/or button. *)
val keybind_arg : string Cmdliner.Term.t

(** An optional [--mode MODE] flag naming the keymap mode a binding belongs to;
    [None] means the default mode. *)
val mode_flag : string option Cmdliner.Term.t

(** [color_arg] is the required trailing [COLOR] positional. *)
val color_arg : Ocdwm_core.Color.t Cmdliner.Term.t

(** [index_arg] is the required trailing [INDEX] positional. *)
val index_arg : int Cmdliner.Term.t

(** [warp_flag] is the exclusive flag pair [--warp] and [--no-warp]. The flag
    overrides the warp on focus configuration for one command. *)
val warp_flag : bool option Cmdliner.Term.t

(** [pattern_flags] is [title_flag], [app_id_flag], [identifier_flag], and
    [case_flag] in a [Pattern.t]. Each criterion is a PCRE regex. A pattern with
    no criterion matches every window. *)
val pattern_flags : Ocdwm_core.Pattern.t Cmdliner.Term.t

(** [pattern_term] is [pattern_flags], but it rejects an empty pattern. *)
val pattern_term : Ocdwm_core.Pattern.t Cmdliner.Term.t

(** [scope_term] is the search scope of a window match: [--focused] for the
    focused output of the seat, [--output NAME] for one named output, and [All]
    when the command line holds neither flag. The term rejects the two flags
    together. *)
val scope_term : Ocdwm_core.Scope.t Cmdliner.Term.t

(** [setting_scope_term] is the target scope of a setting command: the bare form
    for the selected tags on the focused output, [--output NAME] for every tag
    on one named output, and [--all] for every tag on every output. The term
    rejects the two flags together. *)
val setting_scope_term : Ocdwm_core.Scope.t Cmdliner.Term.t

(** [window_match_term] is [pattern_term], [invert_flag], and [scope_term] in a
    [Window_match.t]. It rejects an empty pattern. *)
val window_match_term : Ocdwm_core.Window_match.t Cmdliner.Term.t

(** [window_match_any_term] is [window_match_term], but it permits an empty
    pattern. Such a match selects every window in the scope. *)
val window_match_any_term : Ocdwm_core.Window_match.t Cmdliner.Term.t

(** [tags_flag] is the [--tags TAGS] option: indices, ranges, a bitmask, or the
    literal [occupied]. *)
val tags_flag : Ocdwm_core.Tag.Arg.t option Cmdliner.Term.t

(** [presentation_flag] is the exclusive flag group [--float], [--tile],
    [--fullscreen], [--windowed], [--maximize], and [--fake-fullscreen]; it is
    [None] when the command line holds none of them. *)
val presentation_flag
  : Ocdwm_core.Window_rule.Effects.Presentation.t option Cmdliner.Term.t

(** [resize_to_flag] is the [--resize-to W,H] option. Each half is a pixel size
    or a percentage of the usable area. The term rejects a list that does not
    hold two values. *)
val resize_to_flag : Ocdwm_core.Window_rule.Effects.Resize_to.t option Cmdliner.Term.t

(** [move_to_flag] is the [--move-to X,Y] option. Each half is a pixel offset
    from the top-left of the usable area, or a percentage of it. The term
    rejects a list that does not hold two values. *)
val move_to_flag : Ocdwm_core.Window_rule.Effects.Move_to.t option Cmdliner.Term.t

(** [mk_enum name ~doc ~docv l] is the optional flag --[name] accepting an enum of
    choices defined by [l]. The term appends the choice list to [doc]. *)
val mk_enum
  :  string
  -> doc:string
  -> docv:string
  -> (string * 'a) list
  -> 'a option Cmdliner.Term.t

(** [bool_state] is the enum mapping "enabled" to [true] and "disabled" to
    [false]. *)
val bool_state : bool Cmdliner.Arg.conv

(** [bool_state_arg name ~doc ~docv] is the optional flag --[name]. The flag
    takes enabled or disabled. *)
val bool_state_arg : string -> doc:string -> docv:string -> bool option Cmdliner.Term.t

(** [accel_profile_arg] is the [--accel-profile] flag accepting only valid
    profile names. *)
val accel_profile_arg : Ocdwm_core.Input_rule.Accel_profile.t option Cmdliner.Term.t

(** [accel_speed_arg] is the [--accel-speed] flag taking a speed in the range of
    -1.0 to 1.0. *)
val accel_speed_arg : float option Cmdliner.Term.t

(** [button_map_arg name ~doc] is the --[name] flag accepting a valid button
    map. *)
val button_map_arg
  :  string
  -> doc:string
  -> Ocdwm_core.Input_rule.Button_map.t option Cmdliner.Term.t

(** [drag_lock_arg] is the [--drag-lock] flag accepting a drag lock setting. *)
val drag_lock_arg : Ocdwm_core.Input_rule.Drag_lock.t option Cmdliner.Term.t

(** [three_finger_drag_arg] is the [--three-finger-drag] flag accepting a valid
    three finger drag setting. *)
val three_finger_drag_arg
  : Ocdwm_core.Input_rule.Three_finger_drag.t option Cmdliner.Term.t

(** [click_method_arg] is the [--click-method] flag accepting a valid click
    method. *)
val click_method_arg : Ocdwm_core.Input_rule.Click_method.t option Cmdliner.Term.t

(** [natural_scroll_arg] is the [--natural-scroll] flag to enable or disable
    natural scrolling. *)
val natural_scroll_arg : bool option Cmdliner.Term.t

(** [left_handed_arg] is the [--left-handed] flag to enable or disable left
    handed button layout. *)
val left_handed_arg : bool option Cmdliner.Term.t

(** [middle_emulation_arg] is the [--middle-emulation] flag to enable or disable
    middle-button emulation. *)
val middle_emulation_arg : bool option Cmdliner.Term.t

(** [scroll_factor_arg] is the [--scroll-factor] flag to set the scroll factor. *)
val scroll_factor_arg : float option Cmdliner.Term.t

(** [scroll_method_arg] is the [--scroll-method] flag accepting a valid scroll
    method. *)
val scroll_method_arg : Ocdwm_core.Input_rule.Scroll_method.t option Cmdliner.Term.t

(** [scroll_button_arg] is the [--scroll-button] flag accepting a valid scroll
    button. *)
val scroll_button_arg : Ocdwm_core.Pointer_button.t option Cmdliner.Term.t

(** [send_events_arg] is the [--send-events] flag accepting a valid send event. *)
val send_events_arg : Ocdwm_core.Input_rule.Send_events.t option Cmdliner.Term.t

(** [render_lines json] formats a JSON list reply for display: one line per
    item, with the leading list index. The index is the remove index of the
    item. Nested objects flatten into key=value pairs with the wire names. A
    reply that is not a list prints as raw JSON. *)
val render_lines : Yojson.Safe.t -> string

(** [group ?exits ?man ?man_xrefs ?version ?default ~name ~doc cmds] is a
    command that groups the subcommands [cmds]. Cmdliner evaluates [default]
    when the command line names no subcommand. The fallback term renders the
    group's help. *)
val group
  :  ?exits:Cmdliner.Cmd.Exit.info list
  -> ?man:Cmdliner.Manpage.block list
  -> ?man_xrefs:Cmdliner.Manpage.xref list
  -> ?version:string
  -> ?default:'a Cmdliner.Term.t
  -> name:string
  -> doc:string
  -> 'a Cmdliner.Cmd.t list
  -> 'a Cmdliner.Cmd.t

(** [run_term term] is the evaluation term of [cmd] without the command wrapper.
    It sends [term]'s request body to ocdwm, prints any reply, and exits by the
    outcome. Use it as the [?default] of a command group. *)
val run_term
  :  (Ocdwm_ipc.Request.Body.t * (Yojson.Safe.t -> string) option) Cmdliner.Term.t
  -> int Cmdliner.Term.t

(** [cmd ~name ~doc term] is a command that, when evaluated, sends [term]'s
    request body to ocdwm, prints any reply, and exits by the outcome. *)
val cmd
  :  name:string
  -> doc:string
  -> (Ocdwm_ipc.Request.Body.t * (Yojson.Safe.t -> string) option) Cmdliner.Term.t
  -> int Cmdliner.Cmd.t

(** [stream_cmd ~name ~doc term] is a command that streams subscribe events for
    [term]'s kinds and output filter to stdout, one JSON line each, and exits by
    the outcome. *)
val stream_cmd
  :  name:string
  -> doc:string
  -> (Ocdwm_ipc.Record.t list * string option) Cmdliner.Term.t
  -> int Cmdliner.Cmd.t

(** [command_term term] maps the [term]'s command into a [Command] body. *)
val command_term
  :  Ocdwm_ipc.Command.t Cmdliner.Term.t
  -> (Ocdwm_ipc.Request.Body.t * (Yojson.Safe.t -> string) option) Cmdliner.Term.t

(** [bind_term term] composes [term]'s command with the [to KEYBIND] suffix and
    wraps the result in [Keymap (Bind { keybind; command })]. *)
val bind_term
  :  Ocdwm_ipc.Command.t Cmdliner.Term.t
  -> (Ocdwm_ipc.Request.Body.t * (Yojson.Safe.t -> string) option) Cmdliner.Term.t

(** [query_term ?render query] maps the query into a [Query] body. [render]
    formats the JSON reply for display. The term adds a [--json] flag. With
    [--json], or without [render], octl prints the raw JSON reply. *)
val query_term
  :  ?render:(Yojson.Safe.t -> string)
  -> Ocdwm_ipc.Query.t Cmdliner.Term.t
  -> (Ocdwm_ipc.Request.Body.t * (Yojson.Safe.t -> string) option) Cmdliner.Term.t
