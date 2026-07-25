open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ tags = Ctl_cli.tag_arg
  and+ follow = Ctl_cli.follow_flag in
  Command.Window (Tag { tags; follow })
;;

let name = "set"
let doc = "Set the active TAGS for the focused window"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term command_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term command_term
