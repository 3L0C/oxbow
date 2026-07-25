open! Ocdwm_ipc

let leaves =
  [ "on", "Turn warp-on-focus on", Command.Input (Pointer (Warp true))
  ; "off", "Turn warp-on-focus off", Command.Input (Pointer (Warp false))
  ; "toggle", "Toggle warp-on-focus", Command.Input (Pointer Toggle_warp)
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
