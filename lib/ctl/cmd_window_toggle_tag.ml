open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ tags = Ctl_cli.tag_set
  and+ target = Ctl_cli.target_any_window_term in
  Command.Window (Toggle_tag { tags; target })
;;

let name = "tag"
let doc = "Toggle the active TAGS for the target window"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
