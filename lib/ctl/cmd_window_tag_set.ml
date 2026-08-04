open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ tags = Ctl_cli.tag_arg
  and+ follow = Ctl_cli.follow_flag in
  Command.Window (Tag { tags; follow })
;;

let name = "set"
let doc = "Set the active TAGS for the focused window"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
