let name = "layout"
let doc = "Operations over layouts"

let cmd =
  Ctl_cli.group ~name ~doc
  @@ [ Cmd_layout_tiling.cmd
     ; Cmd_layout_scrolling.cmd
     ; Cmd_layout_floating.cmd
     ; Cmd_layout_query.cmd
     ]
  @ Cmd_layout_cycle.cmds
;;

let bind_cmd =
  Ctl_cli.group ~name ~doc
  @@ [ Cmd_layout_tiling.bind_cmd
     ; Cmd_layout_scrolling.bind_cmd
     ; Cmd_layout_floating.bind_cmd
     ]
  @ Cmd_layout_cycle.bind_cmds
;;
