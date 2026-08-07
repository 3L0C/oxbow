let name = "resize"
let doc = "Resize the focused window"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc
  @@ [ Cmd_window_resize_drag.(cmd, bind_cmd); Cmd_window_resize_to.(cmd, bind_cmd) ]
  @ Cmd_window_resize_spatial.(List.combine cmds bind_cmds)
;;
