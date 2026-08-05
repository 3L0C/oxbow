open! Oxbow_core
open! Oxbow_ipc

(* TODO add an option to sticky a targeted window like window focus where no
   window target means the focused window. *)
let command_term scope = Cmdliner.Term.const @@ Command.Window (Set_sticky scope)
let scope_targets = Ctl_cli.enum_of Sticky.to_string Sticky.all

let mk_leaf (name, policy) =
  Ctl_cli.cmd_pair
    ~name
    ~doc:(Printf.sprintf "Set the focused window sticky scope to %s" name)
  @@ command_term policy
;;

let cmds, bind_cmds = List.map mk_leaf scope_targets |> List.split
