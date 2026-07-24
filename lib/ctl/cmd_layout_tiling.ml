open! Ocdwm_core
open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ global = Ctl_cli.global_flag in
  Command.Set (Layout { layout = Tiling; global })
;;

let name = "tiling"
let doc = "Switch to the tiling layout"

let build mk_term children =
  Ctl_cli.group ~name ~doc ~default:(Ctl_cli.run_term @@ mk_term command_term) children
;;

let cmd =
  build
    Ctl_cli.command_term
    [ Cmd_layout_tiling_scheme.cmd
    ; Cmd_layout_tiling_mfact.cmd
    ; Cmd_layout_tiling_nmaster.cmd
    ; Cmd_layout_tiling_orientation.cmd
    ; Cmd_layout_tiling_stack.cmd
    ]
;;

let bind_cmd =
  build
    Ctl_cli.bind_term
    [ Cmd_layout_tiling_scheme.bind_cmd
    ; Cmd_layout_tiling_mfact.bind_cmd
    ; Cmd_layout_tiling_nmaster.bind_cmd
    ; Cmd_layout_tiling_orientation.bind_cmd
    ; Cmd_layout_tiling_stack.bind_cmd
    ]
;;
