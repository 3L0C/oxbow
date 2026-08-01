open! Ocdwm_ipc

let name = "drag"
let doc = "Begin an interactive move operation on the focused window"

let cmd, bind_cmd =
  Ctl_cli.cmd_pair ~name ~doc @@ Cmdliner.Term.const @@ Command.Window Move_drag
;;
