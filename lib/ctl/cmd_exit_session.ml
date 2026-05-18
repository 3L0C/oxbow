open Ocdwm_core

let cmd =
  Ctl_cli.cmd
    ~name:"exit-session"
    ~doc:"Exit the Wayland session i.e., logout"
    Action.Exit_session
;;
