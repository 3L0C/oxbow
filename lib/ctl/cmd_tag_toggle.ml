open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ tag_set = Ctl_cli.tag_set in
  Command.Tag (Toggle_view tag_set)
;;

let name = "toggle"
let doc = "Toggle the visibility of $(i,TAGS)"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
