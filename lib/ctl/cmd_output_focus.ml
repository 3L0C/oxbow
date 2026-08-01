open! Ocdwm_core
open! Ocdwm_ipc

let dir_command dir =
  let open Cmdliner.Term.Syntax in
  let+ warp = Ctl_cli.warp_flag in
  let open Direction in
  match dir with
  | Logical dir -> Command.Output (Focus_logical { dir; warp })
  | Spatial dir -> Command.Output (Focus_spatial { dir; warp })
;;

let dir_leaf (name, dir) =
  Ctl_cli.cmd_pair ~name ~doc:(Printf.sprintf "Focus the %s output" name)
  @@ dir_command dir
;;

let name_command_term =
  let open Cmdliner.Term.Syntax in
  let+ name = Ctl_cli.output_name_arg
  and+ warp = Ctl_cli.warp_flag in
  Command.Output (Focus_name { name; warp })
;;

let name_leafs =
  Ctl_cli.cmd_pair ~name:"name" ~doc:"Focus the named output" name_command_term
;;

let name = "focus"
let doc = "Focus an output by direction or name"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc
  @@ [ name_leafs ]
  @ List.map dir_leaf Ctl_cli.direction_targets
;;
