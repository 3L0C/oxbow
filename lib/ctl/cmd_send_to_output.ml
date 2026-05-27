open Ocdwm_core

let action_term =
  let open Cmdliner.Term.Syntax in
  let+ name = Ctl_cli.output_name_arg
  and+ policy = Ctl_cli.policy_flag in
  Action.Send_to_output_name { name; policy }
;;

let name = "output"
let doc = "Send to the output matching OUTPUT_NAME"
let cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.trigger_term action_term
let bind_cmd = Ctl_cli.cmd ~name ~doc @@ Ctl_cli.bind_term action_term
