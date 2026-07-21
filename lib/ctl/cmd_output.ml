let name = "output"
let doc = "Operate on outputs"

let cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_output_arrangement.cmd
    ; Cmd_output_focus.cmd
    ; Cmd_output_list.cmd
    ; Cmd_output_overview.cmd
    ]
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_output_arrangement.bind_cmd
    ; Cmd_output_focus.bind_cmd
    ; Cmd_output_overview.bind_cmd
    ]
;;
