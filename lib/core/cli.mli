(** [log_level_arg] is the [--log-level] option: one of error, warning, info, or
    debug. Default is info. *)
val log_level_arg : Logs.level Cmdliner.Term.t

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

(** [group ~name ~doc cmds] is the [cmds] command group; its default term
    renders the group's help. *)
val group
  :  ?man:Cmdliner.Manpage.block list
  -> ?man_xrefs:Cmdliner.Manpage.xref list
  -> ?version:string
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
