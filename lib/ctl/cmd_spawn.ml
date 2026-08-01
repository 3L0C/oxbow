open! Ocdwm_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ cmd =
    Arg.(
      required
      & pos 0 (some string) None
      & info [] ~docv:"STRING" ~doc:"The $(i,STRING) to run as a shell command")
  in
  Command.Spawn cmd
;;

let name = "spawn"
let doc = "Run $(i,STRING) as a shell command, e.g., $(i,/bin/sh -c STRING)"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
