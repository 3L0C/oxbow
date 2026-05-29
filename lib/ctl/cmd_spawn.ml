open! Ocdwm_core

let action_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ cmd =
    Arg.(
      required
      & pos 0 (some string) None
      & info [] ~docv:"STRING" ~doc:"The $(i,STRING) to run as a shell command")
  in
  Action.Spawn cmd
;;

let name = "spawn"
let doc = "Run $(i,STRING) as a shell command, e.g., $(i,/bin/sh -c STRING)"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term action_term
let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
