open! Ocdwm_core
open! Ocdwm_ipc

let leaves =
  [ "on", "Turn warp-on-focus on", Command.Set (Pointer_warp true)
  ; "off", "Turn warp-on-focus off", Command.Set (Pointer_warp false)
  ; "toggle", "Toggle warp-on-focus", Command.Set Toggle_pointer_warp
  ]
;;

let mk_leaf mk_term (name, doc, command) =
  Ctl_cli.cmd ~name ~doc @@ mk_term @@ Cmdliner.Term.const command
;;

let name = "warp"
let doc = "Whether keyboard focus changes warp the pointer"
let build mk_term = Ctl_cli.group ~name ~doc @@ List.map (mk_leaf mk_term) leaves
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
