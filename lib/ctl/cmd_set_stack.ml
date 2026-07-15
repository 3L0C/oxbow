open! Ocdwm_core

let stack_targets =
  List.map (fun k -> Stack_kind.to_string k, k) [ Even; Diminish; Dwindle ]
;;

let leaf mk_term (name, stack_kind) =
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Make the stack %s" name)
  @@ mk_term
  @@ Cmdliner.Term.const
  @@ Action.Set_stack stack_kind
;;

let name = "stack"
let doc = "Set the stacking behavior for the current layout"
let build mk_term = Ctl_cli.group ~name ~doc @@ List.map (leaf mk_term) stack_targets
let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
