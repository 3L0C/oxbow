open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ label = Ctl_cli.label_arg
  and+ target = Ctl_cli.target_any_window_term in
  Command.Window (Label_remove { label; target })
;;

let name = "remove"
let doc = "Remove LABEL from the target window(s)"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
