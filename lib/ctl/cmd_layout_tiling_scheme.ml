open! Ocdwm_core
open! Ocdwm_ipc

let command_term scheme =
  let open Cmdliner.Term.Syntax in
  let+ global = Ctl_cli.global_flag in
  Command.Layout (Tiling (Scheme { scheme; global }))
;;

let leaf mk_term (s : Scheme.t) =
  let name = Scheme.to_string s in
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Switch to the %s tiling scheme" name)
  @@ mk_term
  @@ command_term s
;;

let build mk_term = List.map (leaf mk_term) Scheme.all
let cmds = build Ctl_cli.command_term
let bind_cmds = build Ctl_cli.bind_term
