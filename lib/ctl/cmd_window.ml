let name = "window"
let doc = "Operations over windows"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    ~extra:[ Cmd_window_list.cmd; Cmd_window_query.cmd ]
    [ Cmd_window_close.(cmd, bind_cmd)
    ; Cmd_window_column.(cmd, bind_cmd)
    ; Cmd_window_focus.(cmd, bind_cmd)
    ; Cmd_window_label.(cmd, bind_cmd)
    ; Cmd_window_move.(cmd, bind_cmd)
    ; Cmd_window_resize.(cmd, bind_cmd)
    ; Cmd_window_rule.(cmd, bind_cmd)
    ; Cmd_window_send.(cmd, bind_cmd)
    ; Cmd_window_shift.(cmd, bind_cmd)
    ; Cmd_window_spawn.(cmd, bind_cmd)
    ; Cmd_window_sticky.(cmd, bind_cmd)
    ; Cmd_window_tag.(cmd, bind_cmd)
    ; Cmd_window_toggle.(cmd, bind_cmd)
    ; Cmd_window_zoom.(cmd, bind_cmd)
    ]
;;
