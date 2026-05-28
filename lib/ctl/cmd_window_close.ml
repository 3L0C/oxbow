open! Ocdwm_core

let action_term = Cmdliner.Term.const Action.Close_focused
let name = "close"
let doc = "Close the focused window"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.trigger_term action_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term action_term
