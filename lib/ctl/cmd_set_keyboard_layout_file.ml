open! Ocdwm_core

let action_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ path = Arg.(required & pos 0 (some string) None & info [] ~docv:"PATH") in
  Action.Set_keyboard_layout_file path
;;

let name = "layout-file"
let doc = "Set keyboard keymap from XKB keymap file at PATH"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term action_term
let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
