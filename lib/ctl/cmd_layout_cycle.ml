open! Ocdwm_ipc

let command_term dir = Cmdliner.Term.const @@ Command.Layout (Cycle dir)

let leaf mk_term (name, dir) =
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Cycle to the %s layout" name)
  @@ mk_term
  @@ command_term dir
;;

let build mk_term = List.map (leaf mk_term) Ctl_cli.logical_targets
let cmds = build Ctl_cli.command_term
let bind_cmds = build Ctl_cli.bind_term
