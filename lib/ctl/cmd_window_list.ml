open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ filter = Ctl_cli.window_match_any_term in
  Query.Windows { filter }
;;

let name = "list"
let doc = "List windows matching the search pattern"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.query_term command_term
