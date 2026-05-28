open! Ocdwm_core

let action_term =
  let open Cmdliner.Term.Syntax in
  let+ tag_arg = Ctl_cli.tag_arg in
  Action.Window_tag tag_arg
;;

let name = "tag"
let doc = "Set the active TAGS for the focused window"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.trigger_term action_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term action_term
