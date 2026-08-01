let name = "mode"
let doc = "Declare and switch keymap modes"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    [ Cmd_keymap_mode_declare.(cmd, bind_cmd); Cmd_keymap_mode_enter.(cmd, bind_cmd) ]
;;
