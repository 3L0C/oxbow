open! Oxbow_ipc

let command_term dir =
  let open Cmdliner.Term.Syntax in
  let+ occupied = Ctl_cli.occupied_flag
  and+ follow = Ctl_cli.follow_flag in
  Command.Window
    (if occupied then Tag_shift_occupied { dir; follow } else Tag_shift { dir; follow })
;;

let mk_leaf (name, dir) =
  Ctl_cli.cmd_pair
    ~name
    ~doc:(Printf.sprintf "Shift the focused window to the %s tag" name)
  @@ command_term dir
;;

let cmds, bind_cmds = List.map mk_leaf Ctl_cli.logical_targets |> List.split
