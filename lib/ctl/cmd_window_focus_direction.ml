open! Ocdwm_core
open! Ocdwm_ipc

let command_term dir =
  let open Direction in
  match dir with
  | Logical d -> Cmdliner.Term.const @@ Command.Window (Focus_logical d)
  | Spatial d -> Cmdliner.Term.const @@ Command.Window (Focus_spatial d)
;;

let build mk_term (name, dir) =
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Focus the %s window" name)
  @@ mk_term
  @@ command_term dir
;;

let cmds = List.map (build Ctl_cli.command_term) Ctl_cli.direction_targets
let bind_cmds = List.map (build Ctl_cli.bind_term) Ctl_cli.direction_targets
