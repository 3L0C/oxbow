open! Ocdwm_core
open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ delta = Ctl_cli.int_delta
  and+ global = Ctl_cli.global_flag in
  Command.Set (Gaps_inner { delta; global })
;;

let name = "inner"
let doc = "Set the size of the inner gaps"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term command_term
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
