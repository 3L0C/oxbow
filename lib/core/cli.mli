(** [log_level_arg] is the [--log-level] option: one of error, warning, info, or
    debug. Default is info. *)
val log_level_arg : (string option * Logs.level) list Cmdliner.Term.t

(** [socket] is the [--socket PATH] common option: [PATH] overrides the resolved
    oxbow socket path. *)
val socket_arg : string option Cmdliner.Term.t

(** [info name ~doc] is [Cmdliner.Cmd.info] with [Exit.exits] as the default
    exit information. *)
val info
  :  ?exits:Cmdliner.Cmd.Exit.info list
  -> ?man:Cmdliner.Manpage.block list
  -> ?man_xrefs:Cmdliner.Manpage.xref list
  -> ?version:string
  -> string
  -> doc:string
  -> Cmdliner.Cmd.info

(** [help_term] shows the help of the main command. Pass it as the explicit
    [?default] of the root command group. *)
val help_term : 'a Cmdliner.Term.t

(** [group ?exits ?man ?man_xrefs ?version ?default ~name ~doc cmds] is the
    [cmds] command group. Cmdliner evaluates [default] when the command line
    names no subcommand. The fallback term renders the group's help. *)
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

(** [cmd ~name ~doc term] is the command running [term], with [Exit.exits] as
    the default exit information. *)
val cmd
  :  ?exits:Cmdliner.Cmd.Exit.info list
  -> ?man:Cmdliner.Manpage.block list
  -> ?man_xrefs:Cmdliner.Manpage.xref list
  -> ?version:string
  -> name:string
  -> doc:string
  -> 'a Cmdliner.Term.t
  -> 'a Cmdliner.Cmd.t
