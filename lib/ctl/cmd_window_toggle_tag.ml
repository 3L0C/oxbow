open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ tag_set = Ctl_cli.tag_set in
  Command.Window (Toggle_tag tag_set)
;;

let name = "tag"
let doc = "Toggle the active TAGS for the focused window"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
