open! Oxbow_core
open! Oxbow_ipc

let command_term (dir : Direction.t) =
  let open Cmdliner.Term.Syntax in
  let+ warp = Ctl_cli.warp_flag
  and+ target = Ctl_cli.target_one_window_term in
  let (cmd : Command.Window.t) =
    match dir with
    | Logical dir -> Focus_logical { dir; warp; target }
    | Spatial dir -> Focus_spatial { dir; warp; target }
  in
  Command.Window cmd
;;

let mk_leaf (name, dir) =
  Ctl_cli.cmd_pair ~name ~doc:(Printf.sprintf "Focus the %s window" name)
  @@ command_term dir
;;

let cmds, bind_cmds = List.map mk_leaf Ctl_cli.direction_targets |> List.split
