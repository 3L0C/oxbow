open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ warp = Ctl_cli.warp_flag
  and+ target = Ctl_cli.target_one_window_term in
  Command.Window { cmd = Zoom { warp }; target }
;;

let name = "zoom"
let doc = "Promote the target window to master"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
