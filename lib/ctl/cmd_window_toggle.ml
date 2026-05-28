open! Ocdwm_core

let leaf mk_term (name, doc, action) =
  Ctl_cli.cmd ~name ~doc @@ mk_term @@ Cmdliner.Term.const action
;;

let toggles =
  [ "floating", "Float window if tiled, tile if floating", Action.Toggle_floating
  ; "fullscreen", "Toggle real fullscreen", Action.Toggle_fullscreen
  ; "fake-fullscreen", "Toggle fake fullscreen", Action.Toggle_fake_fullscreen
  ; "maximize", "Toggle maximize", Action.Toggle_maximize
  ]
;;

let tag_cmd mk_term =
  let name = "tag" in
  let doc = "Toggle the active TAGS for the focused window" in
  let action_term =
    let open Cmdliner.Term.Syntax in
    let+ tag_set = Ctl_cli.tag_set in
    Action.Window_toggle_tag tag_set
  in
  Ctl_cli.cmd ~name ~doc @@ mk_term action_term
;;

let name = "toggle"
let doc = "Toggle window state"

let build mk_term =
  Ctl_cli.group ~name ~doc @@ (tag_cmd mk_term :: List.map (leaf mk_term) toggles)
;;

let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
