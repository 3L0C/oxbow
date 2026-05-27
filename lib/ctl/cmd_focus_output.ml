open Ocdwm_core

let action_term =
  let open Cmdliner.Term.Syntax in
  let+ name = Ctl_cli.output_name_arg in
  Action.Focus_output_name name
;;

let name = "output"
let doc = "Focus the output matching OUTPUT_NAME"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.trigger_term action_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term action_term
