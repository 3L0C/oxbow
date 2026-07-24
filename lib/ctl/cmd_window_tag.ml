let name = "tag"
let doc = "Set the active TAGS for the focused window"

let cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_window_tag_set.cmd; Cmd_window_tag_match.cmd; Cmd_window_tag_shift.cmd ]
;;

let bind_cmd =
  Ctl_cli.group
    ~name
    ~doc
    [ Cmd_window_tag_set.bind_cmd
    ; Cmd_window_tag_match.bind_cmd
    ; Cmd_window_tag_shift.bind_cmd
    ]
;;
