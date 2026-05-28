open! Ocdwm_core

let action_term = Cmdliner.Term.const Action.Zoom
let name = "zoom"
let doc = "Promote the focused window to master"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.trigger_term action_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term action_term
