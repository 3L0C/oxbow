open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.target_one_window_term in
  Command.Window { cmd = Toggle_maximize; target }
;;

let name = "maximize"
let doc = "Toggle maximize"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
