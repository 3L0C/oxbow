let name = "keymap"
let doc = "Manage keymaps"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    ~extra:[ Cmd_keymap_list.cmd ]
    [ Cmd_keymap_mode.(cmd, bind_cmd) ]
;;
