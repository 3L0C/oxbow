open! Ocdwm_ipc

let command_term = Cmdliner.Term.const (Command.Output Toggle_overview)
let name = "overview"
let doc = "Toggle the overview grid"

let build mk_term children =
  Ctl_cli.group ~name ~doc ~default:(Ctl_cli.run_term @@ mk_term command_term) children
;;

let cmd = build Ctl_cli.command_term [ Cmd_output_overview_cycle.cmd ]
let bind_cmd = build Ctl_cli.bind_term [ Cmd_output_overview_cycle.bind_cmd ]
