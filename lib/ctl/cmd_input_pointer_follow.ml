open! Ocdwm_ipc

let leaves =
  [ "on", "Turn focus-follows-pointer on", Command.Input (Pointer (Follow true))
  ; "off", "Turn focus-follows-pointer off", Command.Input (Pointer (Follow false))
  ; "toggle", "Toggle focus-follows-pointer", Command.Input (Pointer Toggle_follow)
  ]
;;

let mk_leaf mk_term (name, doc, command) =
  Ctl_cli.cmd ~name ~doc @@ mk_term @@ Cmdliner.Term.const command
;;

let name = "follow"
let doc = "Whether pointer motion changes focus"
let build mk_term = Ctl_cli.group ~name ~doc @@ List.map (mk_leaf mk_term) leaves
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
