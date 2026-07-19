open! Ocdwm_core
open! Ocdwm_ipc

let name = "list"
let doc = "List all the active outputs"

let cmd =
  Ctl_cli.cmd ~name ~doc @@ Ctl_cli.query_term @@ Cmdliner.Term.const Query.Outputs
;;
