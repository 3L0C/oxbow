let name = "toggle"
let doc = "Toggle window state"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc
  @@ [ Cmd_window_toggle_fake_fullscreen.(cmd, bind_cmd)
     ; Cmd_window_toggle_floating.(cmd, bind_cmd)
     ; Cmd_window_toggle_fullscreen.(cmd, bind_cmd)
     ; Cmd_window_toggle_maximize.(cmd, bind_cmd)
     ; Cmd_window_toggle_sticky.(cmd, bind_cmd)
     ; Cmd_window_toggle_swallow.(cmd, bind_cmd)
     ; Cmd_window_toggle_tag.(cmd, bind_cmd)
     ]
;;
