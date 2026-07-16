open! Ocdwm_core
open! Ocdwm_ipc

let command_term kind =
  let open Cmdliner.Term.Syntax in
  let+ tag_arg = Ctl_cli.tag_arg
  and+ app_id = Ctl_cli.app_id_flag
  and+ title = Ctl_cli.title_flag in
  let rule : Rule.t =
    { pattern = { app_id; title }; action = Rule.Action.Set_tags tag_arg }
  in
  match kind with
  | `Add -> Command.Rule (Add rule)
  | `Remove -> Command.Rule (Remove rule)
;;

let name = "tag"
let doc = "Set the default TAGS for matching windows"
let add_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term @@ command_term `Add
let add_bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term @@ command_term `Add
let remove_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term @@ command_term `Remove
let remove_bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term @@ command_term `Remove
