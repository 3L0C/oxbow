open! Ocdwm_core
open! Ocdwm_ipc

let dir_command_term dir =
  let open Cmdliner.Term.Syntax in
  let open Direction in
  let+ policy = Ctl_cli.policy_flag
  and+ follow = Ctl_cli.follow_flag in
  match dir with
  | Logical d -> Command.Window (Send_logical { dir = d; policy; follow })
  | Spatial d -> Command.Window (Send_spatial { dir = d; policy; follow })
;;

let dir_leaf mk_term (name, dir) =
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Send to the %s output" name)
  @@ mk_term (dir_command_term dir)
;;

let to_command_term =
  let open Cmdliner.Term.Syntax in
  let+ name = Ctl_cli.output_name_arg
  and+ policy = Ctl_cli.policy_flag
  and+ follow = Ctl_cli.follow_flag in
  Command.Window (Send_name { name; policy; follow })
;;

let to_leaf mk_term =
  Ctl_cli.cmd ~name:"to" ~doc:"Send to the named output" @@ mk_term to_command_term
;;

let name = "send"
let doc = "Send the focused window to an output by direction or name"

let build mk_term =
  Ctl_cli.group ~name ~doc
  @@ (to_leaf mk_term :: List.map (dir_leaf mk_term) Ctl_cli.direction_targets)
;;

let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
