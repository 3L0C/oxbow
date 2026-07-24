let name = "pointer"
let doc = "Pointer operations and settings"

let cmd =
  Ctl_cli.group ~name ~doc [ Cmd_input_pointer_follow.cmd; Cmd_input_pointer_warp.cmd ]
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_input_pointer_follow.bind_cmd; Cmd_input_pointer_warp.bind_cmd ]
;;
