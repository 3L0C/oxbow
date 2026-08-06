let name = "label"
let doc = "Manage window labels"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    [ Cmd_window_label_add.(cmd, bind_cmd); Cmd_window_label_remove.(cmd, bind_cmd) ]
;;
