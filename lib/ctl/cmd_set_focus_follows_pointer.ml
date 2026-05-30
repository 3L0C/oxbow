open! Ocdwm_core

let leaves =
  [ "on", "Turn focus-follows-pointer on", Action.Set_focus_follows_pointer true
  ; "off", "Turn focus-follows-pointer off", Action.Set_focus_follows_pointer false
  ; "toggle", "Toggle focus-follows-pointer", Action.Toggle_focus_follows_pointer
  ]
;;

let mk_leaf mk_term (name, doc, action) =
  Ctl_cli.cmd ~name ~doc @@ mk_term @@ Cmdliner.Term.const action
;;

let name = "focus-follows-pointer"
let doc = "Whether pointer motion changes focus"
let build mk_term = Ctl_cli.group ~name ~doc @@ List.map (mk_leaf mk_term) leaves
let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
