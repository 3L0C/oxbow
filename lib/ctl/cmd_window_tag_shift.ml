let name = "shift"
let doc = "Shift the focused window's tag in a given direction"
let cmd = Ctl_cli.group ~name ~doc Cmd_window_tag_shift_direction.cmds
let bind_cmd = Ctl_cli.group ~name ~doc Cmd_window_tag_shift_direction.bind_cmds
