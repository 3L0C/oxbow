let name = "border"
let doc = "Border configuration commands"
let cmd = Ctl_cli.group ~name ~doc [ Cmd_set_border_width.cmd; Cmd_set_border_color.cmd ]

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_set_border_width.bind_cmd; Cmd_set_border_color.bind_cmd ]
;;
