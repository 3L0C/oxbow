let name = "add"
let doc = "Add a window rule"
let cmd = Ctl_cli.group ~name ~doc [ Cmd_rule_tag.add_cmd ]
let bind_cmd = Ctl_cli.group ~name ~doc [ Cmd_rule_tag.add_bind_cmd ]
