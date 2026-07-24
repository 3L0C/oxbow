open! Ocdwm_core
open! Ocdwm_ipc

let command_term dir =
  let open Cmdliner.Term.Syntax in
  let+ global = Ctl_cli.global_flag in
  Command.Layout (Tiling (Orientation { dir; global }))
;;

let leaf mk_term (name, dir) =
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Position the master stack %s" name)
  @@ mk_term
  @@ command_term dir
;;

let name = "orientation"
let doc = "Set the master orientation for the current layout"

let build mk_term =
  Ctl_cli.group ~name ~doc @@ List.map (leaf mk_term) Ctl_cli.spatial_targets
;;

let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
