open! Ocdwm_core
open! Ocdwm_ipc

let command_term = Cmdliner.Term.const @@ Command.Tag View_previous
let name = "previous-selection"
let doc = "View the previously selected set of tags"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term command_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term command_term
