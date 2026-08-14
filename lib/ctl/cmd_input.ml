let name = "input"
let doc = "Configure input devices"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    ~extra:[ Cmd_input_list.cmd ]
    [ Cmd_input_cursor.(cmd, bind_cmd)
    ; Cmd_input_keyboard.(cmd, bind_cmd)
    ; Cmd_input_mouse.(cmd, bind_cmd)
    ; Cmd_input_pointer.(cmd, bind_cmd)
    ; Cmd_input_rule.(cmd, bind_cmd)
    ; Cmd_input_touchpad.(cmd, bind_cmd)
    ]
;;
