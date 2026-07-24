let name = "cursor"
let doc = "Configure the cursor appearance"
let cmd = Ctl_cli.group ~name ~doc [ Cmd_input_cursor_theme.cmd ]
let bind_cmd = Ctl_cli.group ~name ~doc [ Cmd_input_cursor_theme.bind_cmd ]
