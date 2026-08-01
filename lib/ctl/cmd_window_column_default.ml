open! Ocdwm_ipc

let command_term = Cmdliner.Term.const @@ Command.Window Column_width_default
let name = "default"
let doc = "Restore the column width to the current tag's default width value"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
