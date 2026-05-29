open! Ocdwm_core

let name = "drag"
let doc = "Begin an interactive move operation on the focused window"

let build mk_term =
  Ctl_cli.cmd ~name ~doc @@ mk_term @@ Cmdliner.Term.const Action.Move_interactive
;;

let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
