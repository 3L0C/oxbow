let name = "scratchpad"
let doc = "Manage window scratchpads"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    [ Cmd_window_scratchpad_add.(cmd, bind_cmd)
    ; Cmd_window_scratchpad_clear.(cmd, bind_cmd)
    ]
;;
