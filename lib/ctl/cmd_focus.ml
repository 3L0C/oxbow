let name = "focus"
let doc = "Focus a window or output by direction or via search query"
let cmd = Ctl_cli.group ~name ~doc @@ (Cmd_focus_window.cmd :: Cmd_focus_direction.cmds)

let bind_cmd =
  Ctl_cli.group ~name ~doc @@ (Cmd_focus_window.bind_cmd :: Cmd_focus_direction.binds)
;;
