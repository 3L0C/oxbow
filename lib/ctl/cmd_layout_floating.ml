open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Select { layout = Floating; scope })
;;

let name = "floating"
let doc = "Switch to the floating layout"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    ~default:command_term
    [ Cmd_layout_floating_seed.(cmd, bind_cmd) ]
;;
