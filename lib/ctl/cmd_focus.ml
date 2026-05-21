let cmd =
  Ctl_cli.group
    ~name:"focus"
    ~doc:"Focus a window or output by direction or via search query"
  @@ (Cmd_focus_window.cmd :: Cmd_focus_direction.cmds)
;;
