open Ocdwm_core

let cmd =
  Ctl_cli.simple_cmd
    ~name:"close-focused"
    ~doc:"Close the focused window"
    Action.Close_focused
;;
