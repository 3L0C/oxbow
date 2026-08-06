let name = "rules"
let doc = "Manage window rules"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    ~extra:[ Cmd_window_rule_list.cmd ]
    [ Cmd_window_rule_add.(cmd, bind_cmd); Cmd_window_rule_remove.(cmd, bind_cmd) ]
;;
