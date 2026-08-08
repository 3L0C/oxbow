open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.target_one_window_term in
  Command.Window (Toggle_fullscreen target)
;;

let name = "fullscreen"
let doc = "Toggle real fullscreen on the target window"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
