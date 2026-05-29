let name = "resize"
let doc = "Resize the focused window"

let cmd =
  Ctl_cli.group
    ~name
    ~doc
    (Cmd_window_resize_drag.cmd
     :: Cmd_window_resize_to.cmd
     :: Cmd_window_resize_spatial.cmds)
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    (Cmd_window_resize_drag.bind_cmd
     :: Cmd_window_resize_to.bind_cmd
     :: Cmd_window_resize_spatial.bind_cmds)
;;
