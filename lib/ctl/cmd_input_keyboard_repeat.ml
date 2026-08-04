open! Oxbow_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ rate = Arg.(required & pos 0 (some int) None & info [] ~docv:"RATE")
  and+ delay = Arg.(required & pos 1 (some int) None & info [] ~docv:"DELAY") in
  Command.Input (Keyboard (Repeat { rate; delay }))
;;

let name = "repeat"
let doc = "Set the keyboard repeat RATE (keys/sec) and DELAY (ms)"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
