let name = "layout"
let doc = "Operations over layouts"
let cmd = Ctl_cli.group ~name ~doc Cmd_layout_cycle.cmds
let bind_cmd = Ctl_cli.group ~name ~doc Cmd_layout_cycle.bind_cmds
