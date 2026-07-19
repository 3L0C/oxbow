open! Ocdwm_core
open! Ocdwm_ipc

let command_term kind =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ name =
    Arg.(
      required
      & pos 0 (some string) None
      & info [] ~docv:"OUTPUT" ~doc:"The name of the output to send matching windows")
  and+ policy = Ctl_cli.policy_flag
  and+ app_id = Ctl_cli.app_id_flag
  and+ title = Ctl_cli.title_flag in
  let rule : Rule.t =
    { pattern = { app_id; title }; action = Rule.Action.Send_to_output { name; policy } }
  in
  match kind with
  | `Add -> Command.Rule (Add rule)
  | `Remove -> Command.Rule (Remove rule)
;;

let name = "send"
let doc = "Send the matching windows to OUTPUT"
let add_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term @@ command_term `Add
let add_bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term @@ command_term `Add
let remove_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term @@ command_term `Remove
let remove_bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term @@ command_term `Remove
