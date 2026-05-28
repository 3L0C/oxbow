let name = "wm"
let doc = "Window-manager control"
let cmd = Ctl_cli.group ~name ~doc [ Cmd_wm_close.cmd ]
let bind_cmd = Ctl_cli.group ~name ~doc [ Cmd_wm_close.bind_cmd ]
