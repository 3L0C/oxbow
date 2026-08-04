open! Oxbow_ipc

let command_term = Cmdliner.Term.const @@ Command.Tag View_previous
let name = "previous-selection"
let doc = "View the previously selected set of tags"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
