let name = "mode"
let doc = "Declare and switch keymap modes"

let cmd =
  Ctl_cli.group ~name ~doc [ Cmd_keymap_mode_declare.cmd; Cmd_keymap_mode_enter.cmd ]
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_keymap_mode_declare.bind_cmd; Cmd_keymap_mode_enter.bind_cmd ]
;;
