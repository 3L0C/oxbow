open! Ocdwm_core
open! Ocdwm_ipc

let body_term =
  let open Cmdliner.Term.Syntax in
  let+ keybind = Ctl_cli.keybind_arg in
  Request.Body.Keymap (Unbind keybind)
;;

let name = "unbind"
let doc = "Unbind the given KEYBIND"
let cmd = Ctl_cli.cmd ~name ~doc body_term
