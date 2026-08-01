open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ tag_arg = Ctl_cli.tag_arg in
  Command.Tag (View tag_arg)
;;

let name = "view"
let doc = "View a set of $(i,TAGS)"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
