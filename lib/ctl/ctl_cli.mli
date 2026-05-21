module Core = Ocdwm_core

val seat : string option Cmdliner.Term.t
val socket : string option Cmdliner.Term.t
val direction : Core.Direction.t Cmdliner.Arg.conv
val stack_kind : Core.Stack_kind.t Cmdliner.Arg.conv
val int_delta : int Core.Delta.t Cmdliner.Arg.conv
val float_delta : float Core.Delta.t Cmdliner.Arg.conv
val tag_set : Core.Tag_set.t Cmdliner.Arg.conv
val tag_arg : Core.Tag_arg.t Cmdliner.Arg.conv

(** [group ?version ~name ~doc cmds] is command that groups the subcommands
    [cmds] *)
val group
  :  ?version:string
  -> name:string
  -> doc:string
  -> 'a Cmdliner.Cmd.t list
  -> 'a Cmdliner.Cmd.t

(** [cmd ~name ~doc action] is a simple command for [action] *)
val cmd : name:string -> doc:string -> Core.Action.t -> int Cmdliner.Cmd.t

(** [cmd_of_term ~name ~doc action_term] is a command with an arbitrary term *)
val cmd_of_term
  :  name:string
  -> doc:string
  -> Core.Action.t Cmdliner.Term.t
  -> int Cmdliner.Cmd.t
