open! Oxbow_ipc

let name = "query"
let doc = "Query the currently focused window"

let cmd =
  Ctl_cli.cmd ~name ~doc @@ Ctl_cli.query_term @@ Cmdliner.Term.const Query.Focused
;;
