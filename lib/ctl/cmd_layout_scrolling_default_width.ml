open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ delta = Ctl_cli.float_delta
  and+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Scrolling (Default_width { delta; scope }))
;;

let name = "default-width"
let doc = "Set the default column width for new windows"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
