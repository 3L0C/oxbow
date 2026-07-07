let name = "rules"
let doc = "Manage window rules"

let cmd =
  Ctl_cli.group ~name ~doc [ Cmd_rule_add.cmd; Cmd_rule_remove.cmd; Cmd_rule_list.cmd ]
;;

let bind_cmd =
  Ctl_cli.group ~name ~doc [ Cmd_rule_add.bind_cmd; Cmd_rule_remove.bind_cmd ]
;;
