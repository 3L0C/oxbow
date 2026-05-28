let name = "output"
let doc = "Operate on outputs"
let cmd = Ctl_cli.group ~name ~doc [ Cmd_output_focus.cmd ]
let bind_cmd = Ctl_cli.group ~name ~doc [ Cmd_output_focus.bind_cmd ]
