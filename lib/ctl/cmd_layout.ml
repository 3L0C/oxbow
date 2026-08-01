let name = "layout"
let doc = "Operations over layouts"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc ~extra:[ Cmd_layout_query.cmd ]
  @@ [ Cmd_layout_tiling.(cmd, bind_cmd)
     ; Cmd_layout_scrolling.(cmd, bind_cmd)
     ; Cmd_layout_floating.(cmd, bind_cmd)
     ]
  @ Cmd_layout_cycle.(List.combine cmds bind_cmds)
;;
