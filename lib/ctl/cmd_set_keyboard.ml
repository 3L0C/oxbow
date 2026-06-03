let name = "keyboard"
let doc = "Configure keyboard input"

let cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_set_keyboard_layout_file.cmd; Cmd_set_keyboard_repeat.cmd ]
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_set_keyboard_layout_file.bind_cmd; Cmd_set_keyboard_repeat.bind_cmd ]
;;
