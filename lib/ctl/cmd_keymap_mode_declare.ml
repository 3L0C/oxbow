open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ name = Ctl_cli.mode_name_arg in
  Command.Keymap (Mode (Declare name))
;;

let name = "declare"
let doc = "Declare a new keymap mode"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
