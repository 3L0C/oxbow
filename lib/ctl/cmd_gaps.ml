let name = "gaps"
let doc = "Configure the gaps between windows"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    [ Cmd_gaps_inner.(cmd, bind_cmd)
    ; Cmd_gaps_outer.(cmd, bind_cmd)
    ; Cmd_gaps_overview.(cmd, bind_cmd)
    ]
;;
