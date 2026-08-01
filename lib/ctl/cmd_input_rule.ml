let name = "rules"
let doc = "Manage input rules"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    ~extra:[ Cmd_input_rule_list.cmd ]
    [ Cmd_input_rule_touchpad.(cmd, bind_cmd)
    ; Cmd_input_rule_mouse.(cmd, bind_cmd)
    ; Cmd_input_rule_remove.(cmd, bind_cmd)
    ]
;;
