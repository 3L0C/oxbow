open! Ocdwm_core

let leaves =
  [ "on", "Turn warp-on-focus on", Action.Set_warp_on_focus true
  ; "off", "Turn warp-on-focus off", Action.Set_warp_on_focus false
  ; "toggle", "Toggle warp-on-focus", Action.Toggle_warp_on_focus
  ]
;;

let mk_leaf mk_term (name, doc, action) =
  Ctl_cli.cmd ~name ~doc @@ mk_term @@ Cmdliner.Term.const action
;;

let name = "warp"
let doc = "Whether keyboard focus changes warp the pointer"
let build mk_term = Ctl_cli.group ~name ~doc @@ List.map (mk_leaf mk_term) leaves
let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
