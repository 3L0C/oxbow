open! Ocdwm_ipc

let leaves =
  [ "floating", "Float window if tiled, tile if floating", Command.Window Toggle_floating
  ; "fullscreen", "Toggle real fullscreen", Command.Window Toggle_fullscreen
  ; "fake-fullscreen", "Toggle fake fullscreen", Command.Window Toggle_fake_fullscreen
  ; "maximize", "Toggle maximize", Command.Window Toggle_maximize
  ]
;;

let tag_cmd_pair =
  let name = "tag" in
  let doc = "Toggle the active TAGS for the focused window" in
  let command_term =
    let open Cmdliner.Term.Syntax in
    let+ tag_set = Ctl_cli.tag_set in
    Command.Window (Toggle_tag tag_set)
  in
  Ctl_cli.cmd_pair ~name ~doc command_term
;;

let name = "toggle"
let doc = "Toggle window state"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc @@ [ tag_cmd_pair ] @ Ctl_cli.const_leaves leaves
;;
