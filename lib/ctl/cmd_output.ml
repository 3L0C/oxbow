let name = "output"
let doc = "Operate on outputs"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    ~extra:[ Cmd_output_list.cmd ]
    [ Cmd_output_column.(cmd, bind_cmd)
    ; Cmd_output_focus.(cmd, bind_cmd)
    ; Cmd_output_label.(cmd, bind_cmd)
    ; Cmd_output_overview.(cmd, bind_cmd)
    ; Cmd_output_swap.(cmd, bind_cmd)
    ]
;;
