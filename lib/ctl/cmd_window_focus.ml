let name = "focus"
let doc = "Focus a window by direction or search query"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc
  @@ [ Cmd_window_focus_match.(cmd, bind_cmd) ]
  @ Cmd_window_focus_direction.(List.combine cmds bind_cmds)
;;
