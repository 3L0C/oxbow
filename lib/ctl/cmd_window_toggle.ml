open! Oxbow_ipc

let leaves =
  [ "floating", "Float window if tiled, tile if floating", Command.Window Toggle_floating
  ; "fullscreen", "Toggle real fullscreen", Command.Window Toggle_fullscreen
  ; "fake-fullscreen", "Toggle fake fullscreen", Command.Window Toggle_fake_fullscreen
  ; "maximize", "Toggle maximize", Command.Window Toggle_maximize
  ; ( "swallow"
    , "Swallow the terminal under the focused window, or release it"
    , Command.Window Toggle_swallow )
  ]
;;

let name = "toggle"
let doc = "Toggle window state"

let cmd, bind_cmd =
  Ctl_cli.group_pair ~name ~doc
  @@ [ Cmd_window_toggle_tag.(cmd, bind_cmd); Cmd_window_toggle_sticky.(cmd, bind_cmd) ]
  @ Ctl_cli.const_leaves leaves
;;
