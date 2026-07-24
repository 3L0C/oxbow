let name = "focus"
let doc = "Focus a window by direction or search query"

let cmd =
  Ctl_cli.group ~name ~doc (Cmd_window_focus_match.cmd :: Cmd_window_focus_direction.cmds)
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    (Cmd_window_focus_match.bind_cmd :: Cmd_window_focus_direction.bind_cmds)
;;
