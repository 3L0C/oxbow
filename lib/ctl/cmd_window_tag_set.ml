open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ tags = Ctl_cli.tag_arg
  and+ follow = Ctl_cli.follow_flag
  and+ target = Ctl_cli.target_any_window_term in
  Command.Window (Tag { tags; follow; target })
;;

let name = "set"
let doc = "Set the active TAGS for the target window(s)"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
