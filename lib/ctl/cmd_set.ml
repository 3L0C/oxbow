let name = "set"
let doc = "Configure ocdwm settings"

let cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_set_border.cmd
    ; Cmd_set_cursor.cmd
    ; Cmd_set_dir.cmd
    ; Cmd_set_focus_follows_pointer.cmd
    ; Cmd_set_gaps_inner.cmd
    ; Cmd_set_gaps_outer.cmd
    ; Cmd_set_keyboard.cmd
    ; Cmd_set_scheme.cmd
    ; Cmd_set_mfact.cmd
    ; Cmd_set_nmaster.cmd
    ; Cmd_set_pointer.cmd
    ; Cmd_set_stack.cmd
    ; Cmd_set_scroll_policy.cmd
    ]
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_set_border.bind_cmd
    ; Cmd_set_cursor.bind_cmd
    ; Cmd_set_dir.bind_cmd
    ; Cmd_set_focus_follows_pointer.bind_cmd
    ; Cmd_set_gaps_inner.bind_cmd
    ; Cmd_set_gaps_outer.bind_cmd
    ; Cmd_set_keyboard.bind_cmd
    ; Cmd_set_scheme.bind_cmd
    ; Cmd_set_mfact.bind_cmd
    ; Cmd_set_nmaster.bind_cmd
    ; Cmd_set_pointer.bind_cmd
    ; Cmd_set_stack.bind_cmd
    ; Cmd_set_scroll_policy.bind_cmd
    ]
;;
