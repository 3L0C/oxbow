let name = "tag"
let doc = "Operate on tag views"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc ~extra:[ Cmd_tag_query.cmd ]
  @@ [ Cmd_tag_previous_selection.(cmd, bind_cmd)
     ; Cmd_tag_toggle.(cmd, bind_cmd)
     ; Cmd_tag_view.(cmd, bind_cmd)
     ]
  @ Cmd_tag_cycle.(List.combine cmds bind_cmds)
;;
