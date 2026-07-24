open! Ocdwm_core
open! Ocdwm_ipc

let command_term dir =
  let open Cmdliner.Term.Syntax in
  let+ global = Ctl_cli.global_flag in
  Command.Set (Stack_cycle { dir; global })
;;

let leaf mk_term (name, dir) =
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Cycle to the %s tiling stack" name)
  @@ mk_term
  @@ command_term dir
;;

let build mk_term = List.map (leaf mk_term) Ctl_cli.logical_targets
let cmds = build Ctl_cli.command_term
let bind_cmds = build Ctl_cli.bind_term
