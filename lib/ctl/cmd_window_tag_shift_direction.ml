open! Oxbow_ipc

let command_term dir =
  let open Cmdliner.Term.Syntax in
  let+ occupied = Ctl_cli.occupied_flag
  and+ follow = Ctl_cli.follow_flag
  and+ target = Ctl_cli.target_any_window_term in
  let (cmd : Command.Window.t) =
    if occupied
    then Tag_shift_occupied { dir; follow; target }
    else Tag_shift { dir; follow; target }
  in
  Command.Window cmd
;;

let mk_leaf (name, dir) =
  Ctl_cli.cmd_pair
    ~name
    ~doc:(Printf.sprintf "Shift the target window to the %s tag" name)
  @@ command_term dir
;;

let cmds, bind_cmds = List.map mk_leaf Ctl_cli.logical_targets |> List.split
