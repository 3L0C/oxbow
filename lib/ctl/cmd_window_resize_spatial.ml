open! Ocdwm_core
open! Ocdwm_ipc

let command_term dir =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ by =
    Arg.(
      required
      & pos 0 (some Ctl_cli.extent_conv) None
      & info
          []
          ~docv:"N"
          ~doc:
            "The distance to resize the window by. May be a pixel offset (e.g. $(b,100)) \
             or a percentage of the usable width (e.g. $(b,25%))")
  in
  Command.Window (Resize_spatial { dir; by })
;;

let build mk_term (name, dir) =
  Ctl_cli.cmd ~name ~doc:(Printf.sprintf "Resize %s by N (px or %%, signed)" name)
  @@ mk_term
  @@ command_term dir
;;

let cmds = List.map (build Ctl_cli.command_term) Ctl_cli.spatial_targets
let bind_cmds = List.map (build Ctl_cli.bind_term) Ctl_cli.spatial_targets
