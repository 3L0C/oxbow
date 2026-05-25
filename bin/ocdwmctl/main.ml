open Cmdliner
open Ocdwm_ctl

let version =
  match Build_info.V1.version () with
  | Some v -> Build_info.V1.Version.to_string v
  | None -> "dev"
;;

let bind_group =
  Ctl_cli.group
    ~name:"bind"
    ~doc:"Bind a key or pointer button to a command"
    [ Cmd_close_focused.bind_cmd
    ; Cmd_close_wm.bind_cmd
    ; Cmd_exit_session.bind_cmd
    ; Cmd_focus.bind_cmd
    ; Cmd_tag_view_previous.bind_cmd
    ; Cmd_toggle_fake_fullscreen.bind_cmd
    ; Cmd_toggle_floating.bind_cmd
    ; Cmd_toggle_fullscreen.bind_cmd
    ; Cmd_toggle_maximize.bind_cmd
    ; Cmd_zoom.bind_cmd
    ]
;;

let cmd =
  Ctl_cli.group
    ~version
    ~name:"ocdwmctl"
    ~doc:"command-line interface for controlling ocdwm"
    [ Cmd_close_focused.cmd
    ; Cmd_close_wm.cmd
    ; Cmd_exit_session.cmd
    ; Cmd_focus.cmd
    ; Cmd_tag_view_previous.cmd
    ; Cmd_toggle_fake_fullscreen.cmd
    ; Cmd_toggle_floating.cmd
    ; Cmd_toggle_fullscreen.cmd
    ; Cmd_toggle_maximize.cmd
    ; Cmd_zoom.cmd
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
