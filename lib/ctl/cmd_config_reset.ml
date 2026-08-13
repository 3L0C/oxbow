open! Oxbow_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ all =
    Arg.(
      value
      & flag
      & info [ "all" ] ~doc:"Reset rules, keybinds, modes, and window/output labels.")
  in
  Command.Config (Reset { all })
;;

let name = "reset"
let doc = "Restore the stock configuration"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
