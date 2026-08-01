open! Ocdwm_ipc

let command_term = Cmdliner.Term.const @@ Command.Window Column_width_cycle
let name = "cycle"
let doc = "Cycle the focused column's width between 1/3, 1/2, and 2/3"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
