let name = "drag"
let doc = "Configure window drag behavior"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc [ Cmd_window_drag_retile.(cmd, bind_cmd) ]
;;
