open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ delta = Ctl_cli.float_delta in
  Command.Output (Column_width delta)
;;

let name = "width"
let doc = "Adjust all columns by $(i,DELTA) width"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term command_term
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
