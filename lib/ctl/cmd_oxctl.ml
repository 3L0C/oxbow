open! Oxbow_core

let bind_group =
  Ctl_cli.group
    ~name:"bind"
    ~doc:"Bind a key or pointer button to a command"
    [ Cmd_border.bind_cmd
    ; Cmd_config.bind_cmd
    ; Cmd_exec.bind_cmd
    ; Cmd_gaps.bind_cmd
    ; Cmd_input.bind_cmd
    ; Cmd_keymap.bind_cmd
    ; Cmd_layout.bind_cmd
    ; Cmd_output.bind_cmd
    ; Cmd_scratchpad.bind_cmd
    ; Cmd_session.bind_cmd
    ; Cmd_spawn.bind_cmd
    ; Cmd_tag.bind_cmd
    ; Cmd_window.bind_cmd
    ; Cmd_wm.bind_cmd
    ]
;;

let cmd ~version =
  Ctl_cli.group
    ~version
    ~default:Cli.help_term
    ~name:"oxctl"
    ~doc:"command-line interface for controlling oxbow"
    [ Cmd_border.cmd
    ; Cmd_config.cmd
    ; Cmd_exec.cmd
    ; Cmd_gaps.cmd
    ; Cmd_input.cmd
    ; Cmd_keymap.cmd
    ; Cmd_layout.cmd
    ; Cmd_output.cmd
    ; Cmd_scratchpad.cmd
    ; Cmd_session.cmd
    ; Cmd_seat.cmd
    ; Cmd_spawn.cmd
    ; Cmd_subscribe.cmd
    ; Cmd_tag.cmd
    ; Cmd_unbind.cmd
    ; Cmd_window.cmd
    ; Cmd_wm.cmd
    ; bind_group
    ]
;;
