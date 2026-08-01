let name = "rules"
let doc = "Manage input rules"

let cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_input_rule_touchpad.cmd
    ; Cmd_input_rule_mouse.cmd
    ; Cmd_input_rule_remove.cmd
    ; Cmd_input_rule_list.cmd
    ]
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_input_rule_touchpad.bind_cmd
    ; Cmd_input_rule_mouse.bind_cmd
    ; Cmd_input_rule_remove.bind_cmd
    ]
;;
