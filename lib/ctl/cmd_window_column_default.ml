open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.target_one_window_term in
  Command.Window (Column_width_default target)
;;

let name = "default"
let doc = "Restore the target window's column width to the tag's default width value"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
