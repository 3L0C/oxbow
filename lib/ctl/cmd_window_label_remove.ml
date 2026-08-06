open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ label = Ctl_cli.label_arg in
  Command.Window (Label_remove label)
;;

let name = "remove"
let doc = "Remove LABEL from the focused window"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
