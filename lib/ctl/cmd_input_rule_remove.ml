open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ index = Ctl_cli.index_arg in
  Command.Input (Rule_remove index)
;;

let name = "remove"
let doc = "Remove an input rule"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term command_term
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
