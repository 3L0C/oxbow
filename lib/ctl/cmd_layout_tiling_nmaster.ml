open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ delta = Ctl_cli.int_delta
  and+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Tiling (Nmaster { delta; scope }))
;;

let name = "nmaster"
let doc = "Set the number of masters in the master stack"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term command_term
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
