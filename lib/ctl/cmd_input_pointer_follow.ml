open! Ocdwm_ipc

let leaves =
  [ "on", "Turn focus-follows-pointer on", Command.Input (Pointer (Follow true))
  ; "off", "Turn focus-follows-pointer off", Command.Input (Pointer (Follow false))
  ; "toggle", "Toggle focus-follows-pointer", Command.Input (Pointer Toggle_follow)
  ]
;;

let name = "follow"
let doc = "Whether pointer motion changes focus"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc @@ Ctl_cli.const_leaves leaves
