open! Cmdliner
open! Ocdwm_core
open! Ocdwm_ctl

let version =
  match Build_info.V1.version () with
  | Some v -> Build_info.V1.Version.to_string v
  | None -> "dev"
;;

let bind_group =
  Ctl_cli.group
    ~name:"bind"
    ~doc:"Bind a key or pointer button to a command"
    [ Cmd_border.bind_cmd
    ; Cmd_exec.bind_cmd
    ; Cmd_gaps.bind_cmd
    ; Cmd_input.bind_cmd
    ; Cmd_keymap.bind_cmd
    ; Cmd_layout.bind_cmd
    ; Cmd_output.bind_cmd
    ; Cmd_rule.bind_cmd
    ; Cmd_session.bind_cmd
    ; Cmd_spawn.bind_cmd
    ; Cmd_tag.bind_cmd
    ; Cmd_window.bind_cmd
    ; Cmd_wm.bind_cmd
    ]
;;

let cmd =
  Ctl_cli.group
    ~version
    ~default:Cli.help_term
    ~name:"octl"
    ~doc:"command-line interface for controlling ocdwm"
    [ Cmd_border.cmd
    ; Cmd_exec.cmd
    ; Cmd_gaps.cmd
    ; Cmd_input.cmd
    ; Cmd_keymap.cmd
    ; Cmd_layout.cmd
    ; Cmd_output.cmd
    ; Cmd_rule.cmd
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

let setup () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.(set_level (Some Info))
;;

let main () =
  setup ();
  Cmd.eval' cmd
;;

let () = if !Sys.interactive then () else exit (main ())
