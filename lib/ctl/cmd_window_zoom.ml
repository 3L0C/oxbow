open! Ocdwm_core
open! Ocdwm_ipc

let command_term = Cmdliner.Term.const @@ Command.Window Zoom
let name = "zoom"
let doc = "Promote the focused window to master"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term command_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term command_term
