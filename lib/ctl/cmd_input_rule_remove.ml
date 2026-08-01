open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ index = Ctl_cli.index_arg in
  Command.Input (Rule_remove index)
;;

let name = "remove"
let doc = "Remove an input rule"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
