open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ name = Ctl_cli.mode_name_arg in
  Command.Keymap (Mode (Enter name))
;;

let name = "enter"
let doc = "Enter the given keymap mode"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
