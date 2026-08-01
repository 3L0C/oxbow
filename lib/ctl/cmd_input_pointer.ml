let name = "pointer"
let doc = "Pointer operations and settings"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    [ Cmd_input_pointer_follow.(cmd, bind_cmd); Cmd_input_pointer_warp.(cmd, bind_cmd) ]
;;
