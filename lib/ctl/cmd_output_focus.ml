open! Ocdwm_core

let dir_action dir =
  let open Ctl_cli.Any_direction in
  match dir with
  | Logical d -> Action.Focus_output_direction d
  | Spatial d -> Action.Focus_output_spatial d
;;

let dir_leaf mk_term (name, dir) =
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Focus the %s output" name)
  @@ mk_term
  @@ Cmdliner.Term.const
  @@ dir_action dir
;;

let name_action_term =
  let open Cmdliner.Term.Syntax in
  let+ name = Ctl_cli.output_name_arg in
  Action.Focus_output_name name
;;

let name_leaf mk_term =
  Ctl_cli.cmd ~name:"name" ~doc:"Focus the named output" @@ mk_term name_action_term
;;

let name = "focus"
let doc = "Focus an output by direction or name"

let build mk_term =
  Ctl_cli.group ~name ~doc
  @@ (name_leaf mk_term :: List.map (dir_leaf mk_term) Ctl_cli.direction_targets)
;;

let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
