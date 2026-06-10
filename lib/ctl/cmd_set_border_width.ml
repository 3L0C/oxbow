open! Ocdwm_core

let action_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ width = Arg.(required & pos 0 (some int32) None & info [] ~docv:"WIDTH") in
  Action.Set_border_width width
;;

let name = "width"
let doc = "Configure the border width"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term action_term
let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
