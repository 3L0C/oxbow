open! Ocdwm_ipc

let command_term = Cmdliner.Term.const (Command.Output Toggle_overview)
let name = "overview"
let doc = "Toggle the overview grid"

let cmd, bind_cmd =
  Ctl_cli.group_pair
    ~name
    ~doc
    ~default:command_term
    [ Cmd_output_overview_cycle.(cmd, bind_cmd) ]
;;
