let name = "shift"
let doc = "Shift the focused window's tag in a given direction"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    Cmd_window_tag_shift_direction.(List.combine cmds bind_cmds)
;;
