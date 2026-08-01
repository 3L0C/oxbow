open! Ocdwm_ipc

let command_term dir = Cmdliner.Term.const @@ Command.Layout (Cycle dir)

let mk_leaf (name, dir) =
  Ctl_cli.cmd_pair ~name ~doc:(Printf.sprintf "Cycle to the %s layout" name)
  @@ command_term dir
;;

let cmds, bind_cmds = List.map mk_leaf Ctl_cli.logical_targets |> List.split
