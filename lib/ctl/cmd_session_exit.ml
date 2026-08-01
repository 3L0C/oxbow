open! Ocdwm_ipc

let command_term = Cmdliner.Term.const @@ Command.Session Exit
let name = "exit"
let doc = "Exit the Wayland session i.e., logout"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
