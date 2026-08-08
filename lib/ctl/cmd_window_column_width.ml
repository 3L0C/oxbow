open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ delta = Ctl_cli.float_delta
  and+ target = Ctl_cli.target_one_window_term in
  Command.Window (Column_width { delta; target })
;;

let name = "width"
let doc = "Set the target window's column width"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
