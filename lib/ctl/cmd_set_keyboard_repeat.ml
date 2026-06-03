open! Ocdwm_core

let action_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ rate = Arg.(required & pos 0 (some int) None & info [] ~docv:"RATE")
  and+ delay = Arg.(required & pos 1 (some int) None & info [] ~docv:"DELAY") in
  Action.Set_keyboard_repeat { rate; delay }
;;

let name = "repeat"
let doc = "Set the keyboard repeat RATE (keys/sec) and DELAY (ms)"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term action_term
let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
