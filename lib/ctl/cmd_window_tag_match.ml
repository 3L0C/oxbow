open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ wmatch = Ctl_cli.window_match_term
  and+ tags = Ctl_cli.tag_arg in
  Command.Window (Tag_match { wmatch; tags })
;;

let name = "match"
let doc = "Set TAGS on all windows matching the search pattern"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
