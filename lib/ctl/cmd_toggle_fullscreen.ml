open Ocdwm_core

let action_term = Cmdliner.Term.const Action.Toggle_fullscreen
let name = "toggle-fullscreen"
let doc = "Toggle fullscreen on the focused window"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.trigger_term action_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term action_term
