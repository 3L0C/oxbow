open Ocdwm_core

let action_term = Cmdliner.Term.const Action.Exit_session
let name = "exit-session"
let doc = "Exit the Wayland session i.e., logout"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.trigger_term action_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term action_term
