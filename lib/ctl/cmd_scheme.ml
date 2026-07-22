let name = "scheme"
let doc = "Operations over schemes"
let cmd = Ctl_cli.group ~name ~doc @@ Cmd_scheme_cycle.cmds @ [ Cmd_scheme_query.cmd ]
let bind_cmd = Ctl_cli.group ~name ~doc Cmd_scheme_cycle.bind_cmds
