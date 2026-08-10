open! Oxbow_ipc

let command_term b = Cmdliner.Term.const @@ Command.Window (Drag_retile b)

let retile_targets =
  [ "enabled", "Retile a dragged tiled window on release", true
  ; "disabled", "Do not retile a dragged tiled window on release; becomes floating", false
  ]
;;

let mk_leaf (name, doc, b) = Ctl_cli.cmd_pair ~name ~doc @@ command_term b
let name = "retile"
let doc = "Configure the drag behavior for tiled windows"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc @@ List.map mk_leaf retile_targets
