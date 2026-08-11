(** [enum_of to_string l] keys each value of [l] by its name. *)
val enum_of : ('a -> string) -> 'a list -> (string * 'a) list

(** [mk_enum name ~doc ~docv l] is the optional flag --[name] accepting an enum of
    choices defined by [l]. The term appends the choice list to [doc]. *)
val mk_enum
  :  string
  -> doc:string
  -> docv:string
  -> (string * 'a) list
  -> 'a option Cmdliner.Term.t

(** [logical_targets] is each logical direction keyed by its name. *)
val logical_targets : (string * Oxbow_core.Direction.Logical.t) list

(** [logical_leaves ~next ~prev] is [logical_targets] with the doc string of
    each direction between the name and the direction. *)
val logical_leaves
  :  next:string
  -> prev:string
  -> (string * string * Oxbow_core.Direction.Logical.t) list

(** [spatial_targets] is each spatial direction keyed by its name. *)
val spatial_targets : (string * Oxbow_core.Direction.Spatial.t) list

(** [direction_targets] is [logical_targets] and [spatial_targets] combined. *)
val direction_targets : (string * Oxbow_core.Direction.t) list

(** [int_delta] is the required leading [DELTA] positional: an absolute value
    ([6]) or a signed offset ([-2]). *)
val int_delta : int Oxbow_core.Delta.t Cmdliner.Term.t

(** [float_delta] is the required leading [DELTA] positional: an absolute value
    ([0.55]) or a signed offset ([-0.05]). *)
val float_delta : float Oxbow_core.Delta.t Cmdliner.Term.t

(** [tag_arg] is the required leading [TAGS] positional: indices, ranges, a
    bitmask, or the literal [occupied]. *)
val tag_arg : Oxbow_core.Tag.Arg.t Cmdliner.Term.t

(** [tag_set] is the required leading [TAGS] positional: indices, ranges, or a
    bitmask. *)
val tag_set : Oxbow_core.Tag.Set.t Cmdliner.Term.t

(** [occupied_flag] is the [--occupied] flag used to restrict tag operations. *)
val occupied_flag : bool Cmdliner.Term.t

(** [policy_flag] is the [--take] flag as a tag policy, [Keep] when absent. *)
val policy_flag : Oxbow_core.Tag.Policy.t Cmdliner.Term.t

(** [follow_flag] is the [--follow] flag, used to signal focus moves with the
    manipulated object. *)
val follow_flag : bool Cmdliner.Term.t

(** [swap_terms mk] is the command and bind term pair of one swap leaf. [mk]
    builds the command from the target, the policy, and the follow flag. *)
val swap_terms
  :  (target:Oxbow_ipc.Command.Output.Swap.Target.t
      -> policy:Oxbow_core.Tag.Policy.t
      -> follow:bool
      -> Oxbow_ipc.Command.t)
  -> Oxbow_ipc.Command.t Cmdliner.Term.t * Oxbow_ipc.Command.t Cmdliner.Term.t

(** [case_flag] is the [-i] / [--ignore-case] flag for a window match; regex
    patterns match case-insensitively when set. *)
val case_flag : Oxbow_core.Pattern.Case.t Cmdliner.Term.t

(** [device_pattern_flag] is the [--name REGEX] flag for a PCRE regex on the input
    device name. *)
val device_pattern_flag : string option Cmdliner.Term.t

(** [output_name_arg] is the required leading [OUTPUT_NAME] positional. *)
val output_name_arg : string Cmdliner.Term.t

(** [output_flag] is the optional [--output NAME] filter flag. *)
val output_flag : string option Cmdliner.Term.t

(** [output_query mk] is [mk] over the [--output NAME] option. *)
val output_query
  :  (string option -> Oxbow_ipc.Query.t)
  -> Oxbow_ipc.Query.t Cmdliner.Term.t

(** [extent_conv] converts an extent argument. *)
val extent_conv : Oxbow_core.Extent.t Cmdliner.Arg.conv

(** [keybind_arg] is the required trailing [KEYBIND] positional: modifiers,
    keysym, and/or button. *)
val keybind_arg : string Cmdliner.Term.t

(** An optional [--mode MODE] flag naming the keymap mode a binding belongs to;
    [None] means the default mode. *)
val mode_flag : string option Cmdliner.Term.t

(** [mode_name_arg] is the required [MODE] positional. *)
val mode_name_arg : string Cmdliner.Term.t

(** [color_arg] is the required trailing [COLOR] positional. *)
val color_arg : Oxbow_core.Color.t Cmdliner.Term.t

(** [index_arg] is the required trailing [INDEX] positional. *)
val index_arg : int Cmdliner.Term.t

(** [warp_flag] is the exclusive flag pair [--warp] and [--no-warp]. The flag
    overrides the warp on focus configuration for one command. *)
val warp_flag : bool option Cmdliner.Term.t

(** [pattern_term] is [title_flag], [app_id_flag], [identifier_flag], and
    [case_flag] in a [Pattern.t]. Each criterion is a PCRE regex. Will error if
    no flag is given. *)
val pattern_term : Oxbow_core.Window_pattern.t Cmdliner.Term.t

(** [setting_scope_term] is the target scope of a setting command: the bare form
    for the selected tags on the focused output, [--output NAME] for every tag
    on one named output, and [--all] for every tag on every output. The term
    rejects the two flags together. *)
val setting_scope_term : Oxbow_core.Scope.t Cmdliner.Term.t

(** [window_match_term] is [pattern_term], [invert_flag], and [scope_term] in a
    [Window_match.t]. It rejects an empty pattern. *)
val window_match_term : Oxbow_core.Window_match.t Cmdliner.Term.t

(** [window_match_any_term] is [window_match_term], but it permits an empty
    pattern. Such a match selects every window in the scope. *)
val window_match_any_term : Oxbow_core.Window_match.t Cmdliner.Term.t

(** [target_any_window_term] is [window_match_any_term], and [--all]/[--cycle]
    to control the match selection. *)
val target_any_window_term : Oxbow_core.Target.Window.Any.t Cmdliner.Term.t

(** [target_one_window_term] is [window_match_any_term], and [--cycle] to control
    the match selection. *)
val target_one_window_term : Oxbow_core.Target.Window.One.t Cmdliner.Term.t

(** [target_one_output_term] is the output match flags, and [--cycle] to
    control the match selection. An empty pattern is the focused output. *)
val target_one_output_term : Oxbow_core.Target.Output.One.t Cmdliner.Term.t

(** [target_any_output_term] is [target_one_output_term], and [--all] to act
    on every match. *)
val target_any_output_term : Oxbow_core.Target.Output.Any.t Cmdliner.Term.t

(** [tags_flag] is the [--tags TAGS] option: indices, ranges, a bitmask, or the
    literal [occupied]. *)
val tags_flag : Oxbow_core.Tag.Arg.t option Cmdliner.Term.t

(** [presentation_flag] is the exclusive flag group [--float], [--tile],
    [--fullscreen], [--windowed], [--maximize], and [--fake-fullscreen]; it is
    [None] when the command line holds none of them. *)
val presentation_flag
  : Oxbow_core.Window_rule.Effects.Presentation.t option Cmdliner.Term.t

(** [extent_pos i ~docv ~doc] is the required extent positional at [i]. *)
val extent_pos : int -> docv:string -> doc:string -> Oxbow_core.Extent.t Cmdliner.Term.t

(** [resize_to_flag] is the [--resize-to W,H] option. Each half is a pixel size
    or a percentage of the usable area. The term rejects a list that does not
    hold two values. *)
val resize_to_flag : Oxbow_core.Window_rule.Effects.Resize_to.t option Cmdliner.Term.t

(** [move_to_flag] is the [--move-to X,Y] option. Each half is a pixel offset
    from the top-left of the usable area, or a percentage of it. The term
    rejects a list that does not hold two values. *)
val move_to_flag : Oxbow_core.Window_rule.Effects.Move_to.t option Cmdliner.Term.t

(** [bool_state_flag name ~doc ~docv] is the optional flag --[name]. The flag
    takes enabled or disabled. *)
val bool_state_flag : string -> doc:string -> docv:string -> bool option Cmdliner.Term.t

(** [accel_profile_flag] is the [--accel-profile] flag accepting only valid
    profile names. *)
val accel_profile_flag : Oxbow_core.Input_rule.Accel_profile.t option Cmdliner.Term.t

(** [accel_speed_flag] is the [--accel-speed] flag taking a speed in the range of
    -1.0 to 1.0. *)
val accel_speed_flag : float option Cmdliner.Term.t

(** [button_map_flag name ~doc] is the --[name] flag accepting a valid button
    map. *)
val button_map_flag
  :  string
  -> doc:string
  -> Oxbow_core.Input_rule.Button_map.t option Cmdliner.Term.t

(** [drag_lock_flag] is the [--drag-lock] flag accepting a drag lock setting. *)
val drag_lock_flag : Oxbow_core.Input_rule.Drag_lock.t option Cmdliner.Term.t

(** [three_finger_drag_flag] is the [--three-finger-drag] flag accepting a valid
    three finger drag setting. *)
val three_finger_drag_flag
  : Oxbow_core.Input_rule.Three_finger_drag.t option Cmdliner.Term.t

(** [click_method_flag] is the [--click-method] flag accepting a valid click
    method. *)
val click_method_flag : Oxbow_core.Input_rule.Click_method.t option Cmdliner.Term.t

(** [natural_scroll_flag] is the [--natural-scroll] flag to enable or disable
    natural scrolling. *)
val natural_scroll_flag : bool option Cmdliner.Term.t

(** [left_handed_flag] is the [--left-handed] flag to enable or disable left
    handed button layout. *)
val left_handed_flag : bool option Cmdliner.Term.t

(** [middle_emulation_flag] is the [--middle-emulation] flag to enable or disable
    middle-button emulation. *)
val middle_emulation_flag : bool option Cmdliner.Term.t

(** [scroll_factor_flag] is the [--scroll-factor] flag to set the scroll factor. *)
val scroll_factor_flag : float option Cmdliner.Term.t

(** [scroll_method_flag] is the [--scroll-method] flag accepting a valid scroll
    method. *)
val scroll_method_flag : Oxbow_core.Input_rule.Scroll_method.t option Cmdliner.Term.t

(** [scroll_button_flag] is the [--scroll-button] flag accepting a valid scroll
    button. *)
val scroll_button_flag : Oxbow_core.Pointer_button.t option Cmdliner.Term.t

(** [send_events_flag] is the [--send-events] flag accepting a valid send event. *)
val send_events_flag : Oxbow_core.Input_rule.Send_events.t option Cmdliner.Term.t

(** [sticky_flag] is the [--sticky] flag accepting a valid sticky scope. *)
val sticky_flag : Oxbow_core.Sticky.t option Cmdliner.Term.t

(** [label_arg] is the required trailing [LABEL] positional. *)
val label_arg : string Cmdliner.Term.t

(** [swallow_flag] is the [--swallow] flag accepting a valid role. *)
val swallow_flag : Oxbow_core.Swallow_role.t option Cmdliner.Term.t

(** [label_as_flag] is the [--label-as] flag accepting a valid label. *)
val label_as_flag : string option Cmdliner.Term.t

(** [scratchpad_flag] is the [--scratchpad] flag accepting a group name. *)
val scratchpad_flag : string option Cmdliner.Term.t

(** [spawn_position_flag] is the [--spawn-position] flag accepting a valid position. *)
val spawn_position_flag : Oxbow_core.Spawn_position.t option Cmdliner.Term.t

(** [spawn_focus_flag] is the [--spawn-focus] flag changes focus on spawn. *)
val spawn_focus_flag : bool option Cmdliner.Term.t

(** [dispatch_command_ref] is the function behind every command leaf. *)
val dispatch_command_ref
  : (?render:(Yojson.Safe.t -> string)
     -> ?seat:string
     -> ?socket:string
     -> Oxbow_ipc.Request.Body.t
     -> int)
      ref

(** [dispatch_stream_ref] is the function behind every subscribe leaf. *)
val dispatch_stream_ref
  : (?socket:string
     -> ?output:string
     -> human:bool
     -> kinds:Oxbow_ipc.Record.t list
     -> unit
     -> int)
      ref

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
    It sends [term]'s request body to oxbow, prints any reply, and exits by the
    outcome. Use it as the [?default] of a command group. *)
val run_term
  :  (Oxbow_ipc.Request.Body.t * (Yojson.Safe.t -> string) option) Cmdliner.Term.t
  -> int Cmdliner.Term.t

(** [cmd ~name ~doc term] is a command that, when evaluated, sends [term]'s
    request body to oxbow, prints any reply, and exits by the outcome. *)
val cmd
  :  name:string
  -> doc:string
  -> (Oxbow_ipc.Request.Body.t * (Yojson.Safe.t -> string) option) Cmdliner.Term.t
  -> int Cmdliner.Cmd.t

(** [stream_cmd ~name ~doc term] is a command that streams subscribe events for
    [term]'s kinds and output filter to stdout, one JSON line each, and exits by
    the outcome. *)
val stream_cmd
  :  name:string
  -> doc:string
  -> (Oxbow_ipc.Record.t list * string option) Cmdliner.Term.t
  -> int Cmdliner.Cmd.t

(** [command_term term] maps the [term]'s command into a [Command] body. *)
val command_term
  :  Oxbow_ipc.Command.t Cmdliner.Term.t
  -> (Oxbow_ipc.Request.Body.t * (Yojson.Safe.t -> string) option) Cmdliner.Term.t

(** [bind_term term] composes [term]'s command with the [to KEYBIND] suffix and
    wraps the result in [Keymap (Bind { keybind; command })]. *)
val bind_term
  :  Oxbow_ipc.Command.t Cmdliner.Term.t
  -> (Oxbow_ipc.Request.Body.t * (Yojson.Safe.t -> string) option) Cmdliner.Term.t

(** [cmd_pair ?bind ~name ~doc term] is the [cmd] and [bind_cmd] pair of one
    leaf. [bind] replaces [term] on the bind side. *)
val cmd_pair
  :  ?bind:Oxbow_ipc.Command.t Cmdliner.Term.t
  -> name:string
  -> doc:string
  -> Oxbow_ipc.Command.t Cmdliner.Term.t
  -> int Cmdliner.Cmd.t * int Cmdliner.Cmd.t

(** [group_pair ?extra ?default ~name ~doc pairs] is the [cmd] and [bind_cmd]
    pair of one group parent. [extra] appends the query-only leaves to the [cmd]
    side. [default] sets the bare-form term of the group. *)
val group_pair
  :  ?extra:int Cmdliner.Cmd.t list
  -> ?default:Oxbow_ipc.Command.t Cmdliner.Term.t
  -> name:string
  -> doc:string
  -> (int Cmdliner.Cmd.t * int Cmdliner.Cmd.t) list
  -> int Cmdliner.Cmd.t * int Cmdliner.Cmd.t

(** [render_event line] renders [line] as key=value pairs. Is [line] unchanged
    if not valid JSON. *)
val render_event : string -> string

(** [render_lines ?fields ~expand json] formats a record reply as an aligned
    table. One column per key, one row per item. [fields] selects and orders the
    columns. Without [expand], scalar cells cap at 15 characters. A reply with
    no rows prints as raw JSON. *)
val render_lines : ?fields:string list -> expand:bool -> Yojson.Safe.t -> string

(** [query_term ?render query] maps the query into a [Query] body. [render]
    formats the JSON reply for display. The term adds a [--json] flag. With
    [--json], or without [render], oxctl prints the raw JSON reply. *)
val query_term
  :  ?render:(?fields:string list -> expand:bool -> Yojson.Safe.t -> string)
  -> Oxbow_ipc.Query.t Cmdliner.Term.t
  -> (Oxbow_ipc.Request.Body.t * (Yojson.Safe.t -> string) option) Cmdliner.Term.t

(** [const_leaves l] is the [cmd_pair] of each constant leaf in [l]: a name, a
    doc, and a fixed command. *)
val const_leaves
  :  (string * string * Oxbow_ipc.Command.t) list
  -> (int Cmdliner.Cmd.t * int Cmdliner.Cmd.t) list
