module Core = Ocdwm_core

(** [cmd ~name ~doc action] is a simple command for [action] *)
val cmd : name:string -> doc:string -> Core.Action.t -> int Cmdliner.Cmd.t

(** [cmd_with_string ~name ~doc ?docv action_of] is a command taking a
    positional string argument *)
val cmd_with_string
  :  name:string
  -> doc:string
  -> ?docv:string
  -> (string -> Core.Action.t)
  -> int Cmdliner.Cmd.t

(** [cmd_with_dir ~name ~doc ?docv action_of] is a command taking a positional
    [Direction.t] argument *)
val cmd_with_dir
  :  name:string
  -> doc:string
  -> ?docv:string
  -> (Core.Direction.t -> Core.Action.t)
  -> int Cmdliner.Cmd.t

(** [cmd_with_int_delta ~name ~doc ?docv action_of] is a command taking a
    positional [int Delta.t] argument *)
val cmd_with_int_delta
  :  name:string
  -> doc:string
  -> ?docv:string
  -> (int Core.Delta.t -> Core.Action.t)
  -> int Cmdliner.Cmd.t

(** [cmd_with_float_delta ~name ~doc ?docv action_of] is a command taking a
    positional [float Delta.t] argument *)
val cmd_with_float_delta
  :  name:string
  -> doc:string
  -> ?docv:string
  -> (float Core.Delta.t -> Core.Action.t)
  -> int Cmdliner.Cmd.t

(** [cmd_with_stack_kind ~name ~doc ?docv action_of] is a command taking a
    positional [Stack_kind.t] argument *)
val cmd_with_stack_kind
  :  name:string
  -> doc:string
  -> ?docv:string
  -> (Core.Stack_kind.t -> Core.Action.t)
  -> int Cmdliner.Cmd.t

(** [cmd_with_tag_set ~name ~doc ?docv action_of] is a command taking a
    positional [Tag_set.t] argument *)
val cmd_with_tag_set
  :  name:string
  -> doc:string
  -> ?docv:string
  -> (Core.Tag_set.t -> Core.Action.t)
  -> int Cmdliner.Cmd.t

(** [cmd_with_tag_arg ~name ~doc ?docv action_of] is a command taking a
    positional [Tag_arg.t] argument *)
val cmd_with_tag_arg
  :  name:string
  -> doc:string
  -> ?docv:string
  -> (Core.Tag_arg.t -> Core.Action.t)
  -> int Cmdliner.Cmd.t

(** [cmd_of_term ~name ~doc action_term] is a command with an arbitrary term *)
val cmd_of_term
  :  name:string
  -> doc:string
  -> Core.Action.t Cmdliner.Term.t
  -> int Cmdliner.Cmd.t
