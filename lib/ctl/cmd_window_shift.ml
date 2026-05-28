open! Ocdwm_core

let leaf mk_term (name, doc, dir) =
  Ctl_cli.cmd ~name ~doc @@ mk_term @@ Cmdliner.Term.const (Action.Shift dir)
;;

let targets =
  let open Direction in
  [ ( to_string Next
    , "Shift focused window toward the tail of the stack. Wraps to the head if focused \
       window is the tail"
    , Next )
  ; ( to_string Prev
    , "Shift focused window toward the head of the stack. Wraps to the tail if focused \
       window is the head"
    , Prev )
  ]
;;

let name = "shift"
let doc = "Shift the focused window through the tile stack"
let build mk_term = Ctl_cli.group ~name ~doc @@ List.map (leaf mk_term) targets
let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
