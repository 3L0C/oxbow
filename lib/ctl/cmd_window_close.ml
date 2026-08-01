open! Ocdwm_ipc

let command_term = Cmdliner.Term.const @@ Command.Window Close
let name = "close"
let doc = "Close the focused window"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
