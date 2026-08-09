let name = "spawn"
let doc = "Configure window spawn behavior"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    [ Cmd_window_spawn_position.(cmd, bind_cmd); Cmd_window_spawn_focus.(cmd, bind_cmd) ]
;;
