open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.target_one_window_term in
  Command.Window (Column_width_cycle target)
;;

let name = "cycle"
let doc = "Cycle the target window's column's width between 1/3, 1/2, and 2/3"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
