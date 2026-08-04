open! Oxbow_ipc

let leaves =
  [ "on", "Turn warp-on-focus on", Command.Input (Pointer (Warp true))
  ; "off", "Turn warp-on-focus off", Command.Input (Pointer (Warp false))
  ; "toggle", "Toggle warp-on-focus", Command.Input (Pointer Toggle_warp)
  ]
;;

let name = "warp"
let doc = "Whether keyboard focus changes warp the pointer"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc @@ Ctl_cli.const_leaves leaves
