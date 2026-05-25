open Ocdwm_core

let action_term = Cmdliner.Term.const Action.Toggle_fake_fullscreen
let name = "toggle-fake-fullscreen"

let doc =
  "Inform the focused window it has been fullscreened without actually making it \
   fullscreen"
;;

let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.trigger_term action_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term action_term
