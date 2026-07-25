open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ warp = Ctl_cli.warp_flag in
  Command.Window (Zoom { warp })
;;

let name = "zoom"
let doc = "Promote the focused window to master"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.command_term command_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term command_term
