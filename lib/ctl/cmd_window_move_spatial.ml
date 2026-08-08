open! Oxbow_ipc

let command_term dir =
  let open Cmdliner.Term.Syntax in
  let+ by =
    Ctl_cli.extent_pos
      0
      ~docv:"N"
      ~doc:
        "The distance to move the window by. May be a pixel offset (e.g. $(b,100)) or a \
         percentage of the usable width (e.g. $(b,25%))"
  and+ target = Ctl_cli.target_any_window_term in
  Command.Window (Move_spatial { dir; by; target })
;;

let mk_leaf (name, dir) =
  Ctl_cli.cmd_pair
    ~name
    ~doc:(Printf.sprintf "Move the target window(s) %s by N (px or %%, signed)" name)
  @@ command_term dir
;;

let cmds, bind_cmds = List.map mk_leaf Ctl_cli.spatial_targets |> List.split
