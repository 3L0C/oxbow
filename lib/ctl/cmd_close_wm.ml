open Ocdwm_core

let cmd =
  Ctl_cli.simple_cmd
    ~name:"close-wm"
    ~doc:"Close ocdwm (leaves River running)"
    Action.Close_wm
;;
