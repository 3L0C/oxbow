open! Ocdwm_core

let action_term =
  let open Cmdliner.Term.Syntax in
  let+ delta = Ctl_cli.int_delta in
  Action.Set_gaps_inner delta
;;

let name = "gaps-inner"
let doc = "Set the size of the inner gaps"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term action_term
let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
