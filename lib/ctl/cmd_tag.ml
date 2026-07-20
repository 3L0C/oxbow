let name = "tag"
let doc = "Operate on tag views"

let cmd =
  Ctl_cli.group ~name ~doc
  @@ [ Cmd_tag_previous_selection.cmd
     ; Cmd_tag_query.cmd
     ; Cmd_tag_toggle.cmd
     ; Cmd_tag_view.cmd
     ]
  @ Cmd_tag_cycle.cmds
;;

let bind_cmd =
  Ctl_cli.group ~name ~doc
  @@ [ Cmd_tag_previous_selection.bind_cmd
     ; Cmd_tag_toggle.bind_cmd
     ; Cmd_tag_view.bind_cmd
     ]
  @ Cmd_tag_cycle.bind_cmds
;;
