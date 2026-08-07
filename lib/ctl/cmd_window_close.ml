open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.target_window_term in
  Command.Window (Close target)
;;

let name = "close"
let doc = "Close the focused window"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
