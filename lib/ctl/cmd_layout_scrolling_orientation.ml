open! Oxbow_core
open! Oxbow_ipc

let command_term dir =
  let open Cmdliner.Term.Syntax in
  let+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Scrolling (Orientation { dir; scope }))
;;

let orientation_targets : (string * string * Direction.Spatial.t) list =
  [ "left", "The strip scrolls horizontally, with the head of the strip on the left", Left
  ; ( "right"
    , "The strip scrolls horizontally, with the head of the strip on the right"
    , Right )
  ; "up", "The strip scrolls vertically, with the head of the strip on the top", Up
  ; "down", "The strip scrolls vertically, with the head of the strip on the bottom", Down
  ]
;;

let mk_leaf (name, doc, dir) = Ctl_cli.cmd_pair ~name ~doc @@ command_term dir
let name = "orientation"
let doc = "Set the orientation of the scrolling layout"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc @@ List.map mk_leaf orientation_targets
