open! Ocdwm_core
open! Ocdwm_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.swap_target
  and+ policy = Ctl_cli.policy_flag in
  Command.Output (Swap (Tags { target; policy }))
;;

let bind_command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.bind_swap_target
  and+ policy = Ctl_cli.policy_flag in
  Command.Output (Swap (Tags { target; policy }))
;;

let name = "tags"
let doc = "Swap windows on TAGS between two outputs"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term command_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term bind_command_term
