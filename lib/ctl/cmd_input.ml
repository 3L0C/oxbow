let name = "input"
let doc = "Configure input devices"

let cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_input_cursor.cmd; Cmd_input_keyboard.cmd; Cmd_input_pointer.cmd ]
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_input_cursor.bind_cmd; Cmd_input_keyboard.bind_cmd; Cmd_input_pointer.bind_cmd ]
;;
