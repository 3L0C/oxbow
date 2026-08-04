open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ delta = Ctl_cli.int_delta
  and+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Tiling (Nmaster { delta; scope }))
;;

let name = "nmaster"
let doc = "Set the number of masters in the master stack"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
