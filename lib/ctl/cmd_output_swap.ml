open! Ocdwm_core
open! Ocdwm_ipc

let name = "swap"
let doc = "Swap windows between outputs"

let cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_output_swap_tags.cmd; Cmd_output_swap_all.cmd; Cmd_output_swap_visible.cmd ]
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_output_swap_tags.bind_cmd
    ; Cmd_output_swap_all.bind_cmd
    ; Cmd_output_swap_visible.bind_cmd
    ]
;;
