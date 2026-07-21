open! Ocdwm_core
open! Ocdwm_ipc

let leaf mk_term (a : Arrangement.t) =
  let name = Arrangement.to_string a in
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Switch to the %s arrangement" name)
  @@ mk_term
  @@ Cmdliner.Term.const
  @@ Command.Output (Arrangement a)
;;

let name = "arrange"
let doc = "Set the output arrangement"

let build mk_term =
  Ctl_cli.group ~name ~doc
  @@ List.map (leaf mk_term) [ Tiling; Scrolling; Overview `Tiling ]
;;

let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
