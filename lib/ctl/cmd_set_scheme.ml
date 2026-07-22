open! Ocdwm_core
open! Ocdwm_ipc

let leaf mk_term (s : Scheme.t) =
  let name = Scheme.to_string s in
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Switch to %s tiling scheme" name)
  @@ mk_term
  @@ Cmdliner.Term.const
  @@ Command.Set (Scheme s)
;;

let name = "scheme"
let doc = "Set the tiling layout scheme"
let build mk_term = Ctl_cli.group ~name ~doc @@ List.map (leaf mk_term) [ Tile; Monocle ]
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
