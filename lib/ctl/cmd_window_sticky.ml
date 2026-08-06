let name = "sticky"
let doc = "Manage window sticky state"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc @@ Cmd_window_sticky_scope.(List.combine cmds bind_cmds)
;;
