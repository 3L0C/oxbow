let name = "remove"
let doc = "Remove a window rule"
let cmd = Ctl_cli.group ~name ~doc [ Cmd_rule_send.remove_cmd; Cmd_rule_tag.remove_cmd ]

let bind_cmd =
  Ctl_cli.group ~name ~doc [ Cmd_rule_send.remove_bind_cmd; Cmd_rule_tag.remove_bind_cmd ]
;;
