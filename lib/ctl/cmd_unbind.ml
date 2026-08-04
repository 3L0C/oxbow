open! Oxbow_ipc

let body_term =
  let open Cmdliner.Term.Syntax in
  let+ keybind = Ctl_cli.keybind_arg
  and+ mode = Ctl_cli.mode_flag in
  Request.Body.Keymap (Unbind { keybind; mode }), None
;;

let name = "unbind"
let doc = "Unbind the given KEYBIND"
let cmd = Ctl_cli.cmd ~name ~doc body_term
