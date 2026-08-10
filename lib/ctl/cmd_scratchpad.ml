let name = "scratchpad"
let doc = "Manage scratchpads"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc [ Cmd_scratchpad_toggle.(cmd, bind_cmd) ]
;;
