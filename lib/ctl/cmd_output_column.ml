let name = "column"
let doc = "Operate on the columns of the focused output"
let cmd = Ctl_cli.group ~name ~doc [ Cmd_output_column_width.cmd ]
let bind_cmd = Ctl_cli.group ~name ~doc [ Cmd_output_column_width.bind_cmd ]
