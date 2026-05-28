let name = "session"
let doc = "Session control"
let cmd = Ctl_cli.group ~name ~doc [ Cmd_session_exit.cmd ]
let bind_cmd = Ctl_cli.group ~name ~doc [ Cmd_session_exit.bind_cmd ]
