open! Ocdwm_core
open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ global = Ctl_cli.global_flag in
  Command.Set (Layout { layout = Scrolling; global })
;;

let name = "scrolling"
let doc = "Switch to the scrolling layout"

let build mk_term children =
  Ctl_cli.group ~name ~doc ~default:(Ctl_cli.run_term @@ mk_term command_term) children
;;

let cmd =
  build
    Ctl_cli.command_term
    [ Cmd_layout_scrolling_column_width.cmd; Cmd_layout_scrolling_policy.cmd ]
;;

let bind_cmd =
  build
    Ctl_cli.bind_term
    [ Cmd_layout_scrolling_column_width.bind_cmd; Cmd_layout_scrolling_policy.bind_cmd ]
;;
