let name = "move"
let doc = "Move the focused window"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc
  @@ [ Cmd_window_move_drag.(cmd, bind_cmd); Cmd_window_move_to.(cmd, bind_cmd) ]
  @ Cmd_window_move_spatial.(List.combine cmds bind_cmds)
;;
