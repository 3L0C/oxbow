open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ pattern = Ctl_cli.pattern_term in
  Command.Rule (Remove pattern)
;;

let name = "remove"
let doc = "Remove a window rule"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term command_term
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
