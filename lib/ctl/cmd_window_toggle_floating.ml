open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.target_any_window_term in
  Command.Window { cmd = Toggle_floating; target }
;;

let name = "floating"
let doc = "Toggle window floating state"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
