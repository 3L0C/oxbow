open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ rule = Ctl_cli.mouse_rule in
  Command.Input (Mouse rule)
;;

let name = "mouse"
let doc = "Configure mouse settings"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
