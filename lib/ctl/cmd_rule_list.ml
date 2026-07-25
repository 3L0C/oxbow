open! Ocdwm_ipc

let name = "list"
let doc = "List all the active window rules"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.query_term @@ Cmdliner.Term.const Query.Rules
