open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ delta = Ctl_cli.float_delta
  and+ global = Ctl_cli.global_flag in
  Command.Layout (Scrolling (Column_width { delta; global }))
;;

let name = "column-width"
let doc = "Set the default column width for the scrolling layout"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term command_term
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
