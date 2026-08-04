open! Oxbow_ipc

let name = "drag"
let doc = "Begin an interactive resize operation on the focused window"

let cmd, bind_cmd =
  Ctl_cli.cmd_pair ~name ~doc @@ Cmdliner.Term.const @@ Command.Window Resize_drag
;;
