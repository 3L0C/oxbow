open! Ocdwm_ipc

let command_term = Cmdliner.Term.const @@ Command.Window Column_width_default
let name = "default"
let doc = "Restore the column width to the current tag's default width value"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term command_term
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
