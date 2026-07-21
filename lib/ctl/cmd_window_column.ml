let name = "column"
let doc = "Operate on the column of the focused window"

let cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_window_column_consume.cmd
    ; Cmd_window_column_release.cmd
    ; Cmd_window_column_move.cmd
    ]
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_window_column_consume.bind_cmd
    ; Cmd_window_column_release.bind_cmd
    ; Cmd_window_column_move.bind_cmd
    ]
;;
