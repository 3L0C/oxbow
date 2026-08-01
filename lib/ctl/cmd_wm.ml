let name = "wm"
let doc = "Window-manager control"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc [ Cmd_wm_close.(cmd, bind_cmd) ]
