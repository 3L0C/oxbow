open! Ocdwm_core
open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ global = Ctl_cli.global_flag in
  Command.Set (Layout { layout = Floating; global })
;;

let name = "floating"
let doc = "Switch to the floating layout"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term command_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term command_term
