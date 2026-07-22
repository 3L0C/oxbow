let name = "output"
let doc = "Operate on outputs"

let cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_output_layout.cmd
    ; Cmd_output_focus.cmd
    ; Cmd_output_list.cmd
    ; Cmd_output_overview.cmd
    ]
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_output_layout.bind_cmd
    ; Cmd_output_focus.bind_cmd
    ; Cmd_output_overview.bind_cmd
    ]
;;
