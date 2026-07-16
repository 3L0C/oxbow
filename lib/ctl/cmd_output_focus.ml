open! Ocdwm_core
open! Ocdwm_ipc

let dir_command dir =
  let open Direction in
  match dir with
  | Logical d -> Command.Output (Focus_logical d)
  | Spatial d -> Command.Output (Focus_spatial d)
;;

let dir_leaf mk_term (name, dir) =
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Focus the %s output" name)
  @@ mk_term
  @@ Cmdliner.Term.const
  @@ dir_command dir
;;

let name_command_term =
  let open Cmdliner.Term.Syntax in
  let+ name = Ctl_cli.output_name_arg in
  Command.Output (Focus_name name)
;;

let name_leaf mk_term =
  Ctl_cli.cmd ~name:"name" ~doc:"Focus the named output" @@ mk_term name_command_term
;;

let name = "focus"
let doc = "Focus an output by direction or name"

let build mk_term =
  Ctl_cli.group ~name ~doc
  @@ (name_leaf mk_term :: List.map (dir_leaf mk_term) Ctl_cli.direction_targets)
;;

let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
