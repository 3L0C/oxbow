open! Ocdwm_core
open! Ocdwm_ipc

let command_term = Cmdliner.Term.const @@ Command.Window Column_width_cycle
let name = "cycle"
let doc = "Cycle the focused column's width between 1/3, 1/2, and 2/3"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term command_term
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
