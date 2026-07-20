let name = "seat"
let doc = "Operate on seats"
let cmd = Ctl_cli.group ~name ~doc [ Cmd_seat_list.cmd ]
