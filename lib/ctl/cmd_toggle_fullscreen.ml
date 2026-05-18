open Ocdwm_core

let cmd =
  Ctl_cli.cmd
    ~name:"toggle-fullscreen"
    ~doc:"Toggle fullscreen on the focused window"
    Action.Toggle_fullscreen
;;
