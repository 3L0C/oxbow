open! Ocdwm_core

let dir_action_term dir =
  let open Cmdliner.Term.Syntax in
  let open Direction in
  let+ policy = Ctl_cli.policy_flag in
  match dir with
  | Logical d -> Action.Send_to_output_logical { dir = d; policy }
  | Spatial d -> Action.Send_to_output_spatial { dir = d; policy }
;;

let dir_leaf mk_term (name, dir) =
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Send to the %s output" name)
  @@ mk_term (dir_action_term dir)
;;

let to_action_term =
  let open Cmdliner.Term.Syntax in
  let+ name = Ctl_cli.output_name_arg
  and+ policy = Ctl_cli.policy_flag in
  Action.Send_to_output_name { name; policy }
;;

let to_leaf mk_term =
  Ctl_cli.cmd ~name:"to" ~doc:"Send to the named output" @@ mk_term to_action_term
;;

let name = "send"
let doc = "Send the focused window to an output by direction or name"

let build mk_term =
  Ctl_cli.group ~name ~doc
  @@ (to_leaf mk_term :: List.map (dir_leaf mk_term) Ctl_cli.direction_targets)
;;

let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
