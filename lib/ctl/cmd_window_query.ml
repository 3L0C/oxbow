let name = "query"
let doc = "Query ocdwm for window information"

let cmd =
  Ctl_cli.group ~name ~doc [ Cmd_window_query_focused.cmd; Cmd_window_query_list.cmd ]
;;
