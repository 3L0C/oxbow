open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ w =
    Ctl_cli.extent_pos
      0
      ~docv:"WIDTH"
      ~doc:
        "The $(i,WIDTH) of the window. May be a fixed pixel size (e.g. $(b,100)) or a \
         percentage of the usable width (e.g. $(b,50%))"
  and+ h =
    Ctl_cli.extent_pos
      1
      ~docv:"HEIGHT"
      ~doc:
        "The $(i,HEIGHT) of the window. May be a fixed pixel size (e.g. $(b,100)) or a \
         percentage of the usable height (e.g. $(b,50%))"
  and+ target = Ctl_cli.target_any_window_term in
  Command.Window (Resize_to { w; h; target })
;;

let name = "to"
let doc = "Resize the target window(s) to $(i,WIDTH) and $(i,HEIGHT)"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
