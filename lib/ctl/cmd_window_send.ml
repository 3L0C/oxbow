open! Oxbow_core
open! Oxbow_ipc

let dir_command_term dir =
  let open Cmdliner.Term.Syntax in
  let open Direction in
  let+ policy = Ctl_cli.policy_flag
  and+ follow = Ctl_cli.follow_flag in
  match dir with
  | Logical d -> Command.Window (Send_logical { dir = d; policy; follow })
  | Spatial d -> Command.Window (Send_spatial { dir = d; policy; follow })
;;

let dir_leaf (name, dir) =
  Ctl_cli.cmd_pair ~name ~doc:(Printf.sprintf "Send to the %s output" name)
  @@ dir_command_term dir
;;

let to_command_term =
  let open Cmdliner.Term.Syntax in
  let+ name = Ctl_cli.output_name_arg
  and+ policy = Ctl_cli.policy_flag
  and+ follow = Ctl_cli.follow_flag in
  Command.Window (Send_name { name; policy; follow })
;;

let to_pair = Ctl_cli.cmd_pair ~name:"to" ~doc:"Send to the named output" to_command_term
let name = "send"
let doc = "Send the focused window to an output by direction or name"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc
  @@ [ to_pair ]
  @ List.map dir_leaf Ctl_cli.direction_targets
;;
