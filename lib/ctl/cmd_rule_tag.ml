open! Ocdwm_core

let action_term kind =
  let open Cmdliner.Term.Syntax in
  let+ tag_arg = Ctl_cli.tag_arg
  and+ app_id = Ctl_cli.app_id_flag
  and+ title = Ctl_cli.title_flag in
  let rule : Window_rule.t =
    { pattern = { app_id; title }; action = Rule_action.Set_tags tag_arg }
  in
  match kind with
  | `Add -> Action.Add_rule rule
  | `Remove -> Action.Remove_rule rule
;;

let name = "tag"
let doc = "Set the default TAGS for matching windows"
let add_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.trigger_term @@ action_term `Add
let add_bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term @@ action_term `Add
let remove_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.trigger_term @@ action_term `Remove
let remove_bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term @@ action_term `Remove
