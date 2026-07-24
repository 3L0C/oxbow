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

(** [app_id_flag] is the [--app-id REGEX] option. *)
val app_id_flag : string option Cmdliner.Term.t

(** [title_flag] is the [--title REGEX] option. *)
val title_flag : string option Cmdliner.Term.t

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

(** [window_query_pattern_arg] is the required trailing [PATTERN] positional for
    a window query. *)
val window_query_pattern_arg : string Cmdliner.Term.t

(** [window_query_pattern_opt_arg] is the optional trailing [PATTERN] positional
    for a window query; [None] matches every window. *)
val window_query_pattern_opt_arg : string option Cmdliner.Term.t

(** [window_query_field_flag] is the [--title], [--app-id], and [--identifier]
    flags for a window query. *)
val window_query_field_flag : Ocdwm_core.Window_query.Field.t Cmdliner.Term.t

(** [window_query_regex_flag] is the [--regex] flag for a window query. *)
val window_query_regex_flag : bool Cmdliner.Term.t

(** [window_query_case_flag] is the [-i] / [--ignore-case] flag for a window
    query; regex patterns match case-insensitively when set. *)
val window_query_case_flag : Ocdwm_core.Window_query.Case.t Cmdliner.Term.t

(** [warp_flag] is the exclusive flag pair [--warp] and [--no-warp]. The flag
    overrides the warp on focus configuration for one command. *)
val warp_flag : bool option Cmdliner.Term.t

(** [global_flag] is the [--all] flag used to apply changes to all tags. *)
val global_flag : bool Cmdliner.Term.t

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
val run_term : Ocdwm_ipc.Request.Body.t Cmdliner.Term.t -> int Cmdliner.Term.t

(** [cmd ~name ~doc term] is a command that, when evaluated, sends [term]'s
    request body to ocdwm, prints any reply, and exits by the outcome. *)
val cmd
  :  name:string
  -> doc:string
  -> Ocdwm_ipc.Request.Body.t Cmdliner.Term.t
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
  -> Ocdwm_ipc.Request.Body.t Cmdliner.Term.t

(** [bind_term term] composes [term]'s command with the [to KEYBIND] suffix and
    wraps the result in [Keymap (Bind { keybind; command })]. *)
val bind_term
  :  Ocdwm_ipc.Command.t Cmdliner.Term.t
  -> Ocdwm_ipc.Request.Body.t Cmdliner.Term.t

(** [query_term query] maps the query into a [Query] body. *)
val query_term
  :  Ocdwm_ipc.Query.t Cmdliner.Term.t
  -> Ocdwm_ipc.Request.Body.t Cmdliner.Term.t
