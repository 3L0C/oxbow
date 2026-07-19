open! Ocdwm_ipc

let name = "focused"
let doc = "Query the currently focused window"

let cmd =
  Ctl_cli.cmd ~name ~doc @@ Ctl_cli.query_term @@ Cmdliner.Term.const Query.Focused
;;
