open! Oxbow_ipc

let command_term dir =
  let open Cmdliner.Term.Syntax in
  let+ occupied = Ctl_cli.occupied_flag in
  if occupied then Command.Tag (View_cycle_occupied dir) else Command.Tag (View_cycle dir)
;;

let mk_leaf (name, doc, dir) = Ctl_cli.cmd_pair ~name ~doc @@ command_term dir

let targets =
  Ctl_cli.logical_leaves
    ~next:"View the next tag, wraps back to the first tag when called from the last tag"
    ~prev:"View the previous tag, wraps back to the last tag when viewing the first tag"
;;

let cmds, bind_cmds = List.map mk_leaf targets |> List.split
