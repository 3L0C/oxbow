open! Ocdwm_core

let action_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ x =
    Arg.(
      required
      & pos 0 (some Ctl_cli.extent_conv) None
      & info
          []
          ~docv:"X"
          ~doc:
            "The $(i,X) position of the window's top-left corner, measured from the left \
             of the output's usable area. A pixel offset (e.g. $(b,100)) or a percentage \
             of the usable width (e.g. $(b,25%) places the left edge a quarter of the \
             way accross)")
  and+ y =
    Arg.(
      required
      & pos 1 (some Ctl_cli.extent_conv) None
      & info
          []
          ~docv:"Y"
          ~doc:
            "The $(i,Y) position of the window's top-left corner, measured from the top \
             of the output's usable area. A pixel offset (e.g. $(b,100)) or a percentage \
             of the usable width/height (e.g. $(b,25%) places the top edge a quarter of \
             the way down)")
  in
  Action.Move_to { x; y }
;;

let name = "to"
let doc = "Move the focused window to point ($(i,X), $(i,Y))"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term action_term
let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
