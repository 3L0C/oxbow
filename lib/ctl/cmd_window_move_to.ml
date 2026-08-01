open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ x =
    Ctl_cli.extent_pos
      0
      ~docv:"X"
      ~doc:
        "The $(i,X) position of the window's top-left corner, measured from the left of \
         the output's usable area. A pixel offset (e.g. $(b,100)) or a percentage of the \
         usable width (e.g. $(b,25%) places the left edge a quarter of the way accross)"
  and+ y =
    Ctl_cli.extent_pos
      1
      ~docv:"Y"
      ~doc:
        "The $(i,Y) position of the window's top-left corner, measured from the top of \
         the output's usable area. A pixel offset (e.g. $(b,100)) or a percentage of the \
         usable width/height (e.g. $(b,25%) places the top edge a quarter of the way \
         down)"
  in
  Command.Window (Move_to { x; y })
;;

let name = "to"
let doc = "Move the focused window to point ($(i,X), $(i,Y))"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
