open Ocdwm_core

let action_term = Cmdliner.Term.const Action.Toggle_floating
let name = "toggle-floating"
let doc = "Float window if tiled, tile if floating"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.trigger_term action_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term action_term
