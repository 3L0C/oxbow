open! Oxbow_ipc

let command_term = Cmdliner.Term.const (Command.Window Column_consume)
let name = "consume"
let doc = "Merge the next column into the focused column"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
