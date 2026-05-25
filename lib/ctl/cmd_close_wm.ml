open Ocdwm_core

let action_term = Cmdliner.Term.const Action.Close_wm
let name = "close-wm"
let doc = "Close ocdwm (leaves River running)"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.trigger_term action_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term action_term
