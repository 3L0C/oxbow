open! Ocdwm_core
open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ tag_set = Ctl_cli.tag_set in
  Command.Tag (Toggle_view tag_set)
;;

let name = "toggle"
let doc = "Toggle the visibility of $(i,TAGS)"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term command_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term command_term
