open! Oxbow_ipc

let command_term = Cmdliner.Term.const (Command.Window Column_release)
let name = "release"
let doc = "Expel the focused window into its own column"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
