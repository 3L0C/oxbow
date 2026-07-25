open! Ocdwm_ipc

let command_term = Cmdliner.Term.const @@ Command.Wm Close
let name = "close"
let doc = "Close ocdwm (leaves River running)"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term command_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term command_term
