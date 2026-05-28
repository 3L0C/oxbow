open! Ocdwm_core

let action_term =
  let open Cmdliner.Term.Syntax in
  let+ tag_set = Ctl_cli.tag_set in
  Action.Tag_toggle_view tag_set
;;

let name = "toggle"
let doc = "Toggle the visibility of $(i,TAGS)"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.trigger_term action_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term action_term
