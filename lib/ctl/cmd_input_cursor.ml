let name = "cursor"
let doc = "Configure the cursor appearance"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc [ Cmd_input_cursor_theme.(cmd, bind_cmd) ]
;;
