let name = "window"
let doc = "Operate on the focused window"

let cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_window_close.cmd
    ; Cmd_window_focus.cmd
    ; Cmd_window_move.cmd
    ; Cmd_window_resize.cmd
    ; Cmd_window_send.cmd
    ; Cmd_window_shift.cmd
    ; Cmd_window_tag.cmd
    ; Cmd_window_toggle.cmd
    ; Cmd_window_zoom.cmd
    ]
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_window_close.bind_cmd
    ; Cmd_window_focus.bind_cmd
    ; Cmd_window_move.bind_cmd
    ; Cmd_window_resize.bind_cmd
    ; Cmd_window_send.bind_cmd
    ; Cmd_window_shift.bind_cmd
    ; Cmd_window_tag.bind_cmd
    ; Cmd_window_toggle.bind_cmd
    ; Cmd_window_zoom.bind_cmd
    ]
;;
