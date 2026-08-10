open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.target_any_window_term in
  Command.Window (Scratchpad_clear { target })
;;

let name = "clear"
let doc = "Clear the target window(s) from their scratchpad group"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
