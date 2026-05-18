open Ocdwm_core

let cmd =
  Ctl_cli.cmd
    ~name:"toggle-floating"
    ~doc:"Float window if tiled, tile if floating"
    Action.Toggle_floating
;;
