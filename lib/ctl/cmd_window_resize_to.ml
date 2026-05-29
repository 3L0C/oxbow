open! Ocdwm_core

let action_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ w =
    Arg.(
      required
      & pos 0 (some Ctl_cli.extent_conv) None
      & info
          []
          ~docv:"WIDTH"
          ~doc:
            "The $(i,WIDTH) of the window. May be a fixed pixel size (e.g. $(b,100)) or \
             a percentage of the usable width (e.g. $(b,50%))")
  and+ h =
    Arg.(
      required
      & pos 1 (some Ctl_cli.extent_conv) None
      & info
          []
          ~docv:"HEIGHT"
          ~doc:
            "The $(i,HEIGHT) of the window. May be a fixed pixel size (e.g. $(b,100)) or \
             a percentage of the usable height (e.g. $(b,50%))")
  in
  Action.Resize_to { w; h }
;;

let name = "to"
let doc = "Resize the focused window to $(i,WIDTH) and $(i,HEIGHT)"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term action_term
let cmd = build Ctl_cli.trigger_term
let bind_cmd = build Ctl_cli.bind_term
