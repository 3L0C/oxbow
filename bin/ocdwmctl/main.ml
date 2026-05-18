open Cmdliner
open Ocdwm_ctl

let cmd =
  let default = Term.(ret (const (`Help (`Auto, None)))) in
  Cmd.group (Cmd.info "ocdwmctl") ~default
  @@ [ Cmd_close_focused.cmd
     ; Cmd_close_wm.cmd
     ; Cmd_exit_session.cmd
     ; Cmd_send_to.cmd
     ; Cmd_tag_view_previous.cmd
     ; Cmd_toggle_fake_fullscreen.cmd
     ; Cmd_toggle_floating.cmd
     ; Cmd_toggle_fullscreen.cmd
     ; Cmd_toggle_maximize.cmd
     ; Cmd_zoom.cmd
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
