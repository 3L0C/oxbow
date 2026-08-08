open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.target_one_window_term in
  Command.Window (Column_release target)
;;

let name = "release"
let doc = "Expel the target window into its own column"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
