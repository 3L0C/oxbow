let name = "move"
let doc = "Move the focused window"

let cmd =
  Ctl_cli.group
    ~name
    ~doc
    (Cmd_window_move_drag.cmd :: Cmd_window_move_to.cmd :: Cmd_window_move_spatial.cmds)
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    (Cmd_window_move_drag.bind_cmd
     :: Cmd_window_move_to.bind_cmd
     :: Cmd_window_move_spatial.bind_cmds)
;;
