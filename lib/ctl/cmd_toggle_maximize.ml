open Ocdwm_core

let cmd =
  Ctl_cli.cmd
    ~name:"toggle-maximize"
    ~doc:"Maximize or unmaximize the focused window"
    Action.Toggle_maximize
;;
