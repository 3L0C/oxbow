let name = "keymap"
let doc = "Manage keymaps"
let cmd = Ctl_cli.group ~name ~doc [ Cmd_keymap_mode.cmd ]
let bind_cmd = Ctl_cli.group ~name ~doc [ Cmd_keymap_mode.bind_cmd ]
