open! Ocdwm_core
open! Ocdwm_ipc

let command_term scheme =
  let open Cmdliner.Term.Syntax in
  let+ global = Ctl_cli.global_flag in
  Command.Set (Scheme { scheme; global })
;;

let leaf mk_term (s : Scheme.t) =
  let name = Scheme.to_string s in
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Switch to %s tiling scheme" name)
  @@ mk_term
  @@ command_term s
;;

let name = "scheme"
let doc = "Set the tiling layout scheme"

let build mk_term extra =
  Ctl_cli.group ~name ~doc @@ List.map (leaf mk_term) [ Tile; Monocle ] @ extra
;;

let cmd =
  build Ctl_cli.command_term
  @@ Cmd_layout_tiling_scheme_cycle.cmds
  @ [ Cmd_layout_tiling_scheme_query.cmd ]
;;

let bind_cmd = build Ctl_cli.bind_term Cmd_layout_tiling_scheme_cycle.bind_cmds
