open! Ocdwm_core
open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ tag_arg = Ctl_cli.tag_arg in
  Command.Window (Tag tag_arg)
;;

let name = "tag"
let doc = "Set the active TAGS for the focused window"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term command_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term command_term
