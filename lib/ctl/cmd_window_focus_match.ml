open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.target_one_window_term
  and+ warp = Ctl_cli.warp_flag in
  Command.Window { cmd = Focus_match { warp }; target }
;;

let name = "match"
let doc = "Focus a window matching the search pattern"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
