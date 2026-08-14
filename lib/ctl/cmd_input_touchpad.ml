open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ rule = Ctl_cli.touchpad_rule in
  Command.Input (Touchpad rule)
;;

let name = "touchpad"
let doc = "Configure touchpad settings"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
