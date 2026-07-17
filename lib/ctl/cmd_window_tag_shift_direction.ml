open! Ocdwm_core
open! Ocdwm_ipc

let command_term dir =
  let open Cmdliner.Term.Syntax in
  let+ occupied = Ctl_cli.occupied_flag in
  let open Direction in
  Command.Window (if occupied then Tag_shift_occupied dir else Tag_shift dir)
;;

let build mk_term (name, dir) =
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Shift the focused window to the %s tag" name)
  @@ mk_term
  @@ command_term dir
;;

let cmds = List.map (build Ctl_cli.command_term) Ctl_cli.logical_targets
let bind_cmds = List.map (build Ctl_cli.bind_term) Ctl_cli.logical_targets
