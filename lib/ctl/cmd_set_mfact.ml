open! Ocdwm_core

let action_term =
  let open Cmdliner.Term.Syntax in
  let+ delta = Ctl_cli.float_delta in
  Action.Set_mfact delta
;;

let name = "mfact"
let doc = "Set the ratio for the master stack"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term action_term
let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
