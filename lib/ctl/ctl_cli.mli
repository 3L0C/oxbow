module Core = Ocdwm_core

val seat : string option Cmdliner.Term.t
val socket : string option Cmdliner.Term.t
val logical_targets : (string * Core.Logical_direction.t) list
val spatial_targets : (string * Core.Spatial_direction.t) list
val direction_targets : (string * Core.Any_direction.t) list
val int_delta : int Core.Delta.t Cmdliner.Term.t
val float_delta : float Core.Delta.t Cmdliner.Term.t
val tag_arg : Core.Tag_arg.t Cmdliner.Term.t
val tag_set : Core.Tag_set.t Cmdliner.Term.t
val policy_flag : Core.Tag_policy.t Cmdliner.Term.t
val app_id_flag : string option Cmdliner.Term.t
val title_flag : string option Cmdliner.Term.t
val output_name_arg : string Cmdliner.Term.t
val extent_conv : Core.Extent.t Cmdliner.Arg.conv
val keybind_arg : string Cmdliner.Term.t

(** [group ?man ?man_xrefs ?version ~name ~doc cmds] is command that groups the
    subcommands [cmds]. *)
val group
  :  ?man:Cmdliner.Manpage.block list
  -> ?man_xrefs:Cmdliner.Manpage.xref list
  -> ?version:string
  -> name:string
  -> doc:string
  -> 'a Cmdliner.Cmd.t list
  -> 'a Cmdliner.Cmd.t

(** [cmd ~name ~doc term] is a command with an arbitrary term. *)
val cmd
  :  name:string
  -> doc:string
  -> Core.Request_body.t Cmdliner.Term.t
  -> int Cmdliner.Cmd.t

(** [trigger_term term] maps the action into a [Trigger] body. *)
val trigger_term : Core.Action.t Cmdliner.Term.t -> Core.Request_body.t Cmdliner.Term.t

(** [bind_term term] composes the action with the [to KEYBIND] suffix and wraps
    the result in [Setting (Bind { keybind; action })]. *)
val bind_term : Core.Action.t Cmdliner.Term.t -> Core.Request_body.t Cmdliner.Term.t

(** [query_term query] maps the query into a [Query] body. *)
val query_term : Core.Query.t Cmdliner.Term.t -> Core.Request_body.t Cmdliner.Term.t
