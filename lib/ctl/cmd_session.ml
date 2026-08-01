let name = "session"
let doc = "Session control"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc [ Cmd_session_exit.(cmd, bind_cmd) ]
