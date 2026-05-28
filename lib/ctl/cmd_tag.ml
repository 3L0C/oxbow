let name = "tag"
let doc = "Operate on tag views"
let cmd = Ctl_cli.group ~name ~doc [ Cmd_tag_previous.cmd ]
let bind_cmd = Ctl_cli.group ~name ~doc [ Cmd_tag_previous.bind_cmd ]
