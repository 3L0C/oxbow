open! Oxbow_core
open! Oxbow_ipc

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

let name = "focus"
let doc = "Focus an output by direction or match pattern"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc
  @@ [ Cmd_output_focus_match.(cmd, bind_cmd) ]
  @ List.map dir_leaf Ctl_cli.direction_targets
;;
