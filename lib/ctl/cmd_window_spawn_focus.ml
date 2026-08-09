open! Oxbow_ipc

let command_term b = Cmdliner.Term.const @@ Command.Window (Spawn_focus b)

let focus_targets =
  [ "enabled", "Focus windows on spawn", true
  ; "disabled", "Do not focus windows on spawn", false
  ]
;;

let mk_leaf (name, doc, b) = Ctl_cli.cmd_pair ~name ~doc @@ command_term b
let name = "focus"
let doc = "Focus configuration for newly spawned windows"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc @@ List.map mk_leaf focus_targets
