open! Ocdwm_core
open! Ocdwm_ipc

let command_term (dir : Direction.t) =
  let open Cmdliner.Term.Syntax in
  let+ warp = Ctl_cli.warp_flag in
  match dir with
  | Logical dir -> Command.Window (Focus_logical { dir; warp })
  | Spatial dir -> Command.Window (Focus_spatial { dir; warp })
;;

let mk_leaf (name, dir) =
  Ctl_cli.cmd_pair ~name ~doc:(Printf.sprintf "Focus the %s window" name)
  @@ command_term dir
;;

let cmds, bind_cmds = List.map mk_leaf Ctl_cli.direction_targets |> List.split
