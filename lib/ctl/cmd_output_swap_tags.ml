open! Ocdwm_ipc

let mk_command_term swap_target =
  let open Cmdliner.Term.Syntax in
  let+ target = swap_target
  and+ policy = Ctl_cli.policy_flag
  and+ follow = Ctl_cli.follow_flag in
  Command.Output (Swap (Tags { target; policy; follow }))
;;

let command_term = mk_command_term Ctl_cli.swap_target
let bind_command_term = mk_command_term Ctl_cli.bind_swap_target
let name = "tags"
let doc = "Swap windows on TAGS between two outputs"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term command_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term bind_command_term
