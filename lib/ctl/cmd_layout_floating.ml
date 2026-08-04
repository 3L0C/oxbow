open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Select { layout = Floating; scope })
;;

let name = "floating"
let doc = "Switch to the floating layout"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
