open! Ocdwm_core
open! Ocdwm_ipc

let command_term (dir : Direction.t) =
  let open Cmdliner.Term.Syntax in
  let+ warp = Ctl_cli.warp_flag in
  match dir with
  | Logical dir -> Command.Window (Focus_logical { dir; warp })
  | Spatial dir -> Command.Window (Focus_spatial { dir; warp })
;;

let build mk_term (name, dir) =
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Focus the %s window" name)
  @@ mk_term
  @@ command_term dir
;;

let cmds = List.map (build Ctl_cli.command_term) Ctl_cli.direction_targets
let bind_cmds = List.map (build Ctl_cli.bind_term) Ctl_cli.direction_targets
