open! Ocdwm_core
open! Ocdwm_ipc

let term = Cmdliner.Term.const (Command.Window Column_consume)
let name = "consume"
let doc = "Merge the next column into the focused column"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term term
