open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ label = Ctl_cli.label_arg in
  Command.Window (Label_add label)
;;

let name = "add"
let doc = "Add a label to the focused window"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
