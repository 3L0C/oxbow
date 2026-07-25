open! Ocdwm_ipc

let term = Cmdliner.Term.const (Command.Output Toggle_overview)
let name = "overview"
let doc = "Toggle the overview grid"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term term
