open Ocdwm_core

let cmd =
  Ctl_cli.simple_cmd
    ~name:"toggle-fake-fullscreen"
    ~doc:
      "Inform the focused window it has been fullscreened without actually making it \
       fullscreen"
    Action.Toggle_fake_fullscreen
;;
