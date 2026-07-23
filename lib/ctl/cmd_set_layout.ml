open! Ocdwm_core
open! Ocdwm_ipc

let command_term layout =
  let open Cmdliner.Term.Syntax in
  let+ global = Ctl_cli.global_flag in
  Command.Set (Layout { layout; global })
;;

let leaf mk_term (l : Layout.t) =
  let name = Layout.to_string l in
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Switch to %s layout" name)
  @@ mk_term
  @@ command_term l
;;

let name = "layout"
let doc = "Set the first focused tag's layout"

let build mk_term =
  Ctl_cli.group ~name ~doc @@ List.map (leaf mk_term) [ Tiling; Floating; Scrolling ]
;;

let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
