open Ocdwm_core

let name = "shift"
let doc = "Shift the focused window through the tile stack"

let leaf ~name ~doc ~dir mk_term =
  Ctl_cli.cmd ~name ~doc @@ mk_term @@ Cmdliner.Term.const @@ Action.Shift dir
;;

let targets =
  [ ( "next"
    , "Shift focused window one slot toward the tail of the stack. Wraps to the head if \
       the focused window is the tail"
    , Direction.Next )
  ; ( "prev"
    , "Shift focused window one slot toward the head of the stack. Wraps to the tail if \
       the focused window is the head"
    , Direction.Prev )
  ]
;;

let cmd =
  Ctl_cli.group ~name ~doc
  @@ List.map (fun (n, d, dir) -> leaf ~name:n ~doc:d ~dir Ctl_cli.trigger_term) targets
;;

let bind_cmd =
  Ctl_cli.group ~name ~doc
  @@ List.map (fun (n, d, dir) -> leaf ~name:n ~doc:d ~dir Ctl_cli.bind_term) targets
;;
