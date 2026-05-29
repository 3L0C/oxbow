let name = "focus"
let doc = "Focus a window by direction or search query"

let cmd =
  Ctl_cli.group ~name ~doc (Cmd_window_focus_query.cmd :: Cmd_window_focus_direction.cmds)
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    (Cmd_window_focus_query.bind_cmd :: Cmd_window_focus_direction.bind_cmds)
;;
