open! Oxbow_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ path = Arg.(required & pos 0 (some string) None & info [] ~docv:"PATH") in
  Command.Input (Keyboard (Layout_file path))
;;

let name = "layout-file"
let doc = "Set keyboard keymap from XKB keymap file at PATH"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
