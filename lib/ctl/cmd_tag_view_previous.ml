open Ocdwm_core

let action_term = Cmdliner.Term.const Action.Tag_view_previous
let name = "tag-view-previous"
let doc = "View the previously selected set of tags"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.trigger_term action_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term action_term
