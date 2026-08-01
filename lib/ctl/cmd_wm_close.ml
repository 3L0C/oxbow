open! Ocdwm_ipc

let command_term = Cmdliner.Term.const @@ Command.Wm Close
let name = "close"
let doc = "Close ocdwm (leaves River running)"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
