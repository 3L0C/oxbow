open Ocdwm_core

let cmd =
  Ctl_cli.simple_cmd
    ~name:"toggle-floating"
    ~doc:"Float window if tiled, tile if floating"
    Action.Toggle_floating
;;
