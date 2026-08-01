let name = "rules"
let doc = "Manage window rules"

let cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_window_rule_add.cmd; Cmd_window_rule_remove.cmd; Cmd_window_rule_list.cmd ]
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_window_rule_add.bind_cmd; Cmd_window_rule_remove.bind_cmd ]
;;
