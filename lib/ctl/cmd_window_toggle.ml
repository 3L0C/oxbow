open! Ocdwm_ipc

let leaf mk_term (name, doc, command) =
  Ctl_cli.cmd ~name ~doc @@ mk_term @@ Cmdliner.Term.const command
;;

let toggles =
  [ "floating", "Float window if tiled, tile if floating", Command.Window Toggle_floating
  ; "fullscreen", "Toggle real fullscreen", Command.Window Toggle_fullscreen
  ; "fake-fullscreen", "Toggle fake fullscreen", Command.Window Toggle_fake_fullscreen
  ; "maximize", "Toggle maximize", Command.Window Toggle_maximize
  ]
;;

let tag_cmd mk_term =
  let name = "tag" in
  let doc = "Toggle the active TAGS for the focused window" in
  let command_term =
    let open Cmdliner.Term.Syntax in
    let+ tag_set = Ctl_cli.tag_set in
    Command.Window (Toggle_tag tag_set)
  in
  Ctl_cli.cmd ~name ~doc @@ mk_term command_term
;;

let name = "toggle"
let doc = "Toggle window state"

let build mk_term =
  Ctl_cli.group ~name ~doc @@ (tag_cmd mk_term :: List.map (leaf mk_term) toggles)
;;

let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
