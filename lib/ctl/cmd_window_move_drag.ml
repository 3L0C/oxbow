open! Ocdwm_core
open! Ocdwm_ipc

let name = "drag"
let doc = "Begin an interactive move operation on the focused window"

let build mk_term =
  Ctl_cli.cmd ~name ~doc @@ mk_term @@ Cmdliner.Term.const @@ Command.Window Move_drag
;;

let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
