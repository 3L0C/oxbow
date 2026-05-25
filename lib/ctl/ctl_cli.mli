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
    [cmds]. *)
val group
  :  ?version:string
  -> name:string
  -> doc:string
  -> 'a Cmdliner.Cmd.t list
  -> 'a Cmdliner.Cmd.t

(** [cmd ~name ~doc body_term] is a command with an arbitrary term. *)
val cmd
  :  name:string
  -> doc:string
  -> Core.Request_body.t Cmdliner.Term.t
  -> int Cmdliner.Cmd.t

(** [trigger_term action_term] maps the action into a [Trigger] body. *)
val trigger_term : Core.Action.t Cmdliner.Term.t -> Core.Request_body.t Cmdliner.Term.t

(** [bind_term action_term] composes the action with the [to KEYBIND] suffix and
    wraps the result in [Setting (Bind { keybind; action })]. *)
val bind_term : Core.Action.t Cmdliner.Term.t -> Core.Request_body.t Cmdliner.Term.t
