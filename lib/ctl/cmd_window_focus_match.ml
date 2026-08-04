open! Oxbow_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ wmatch = Ctl_cli.window_match_term
  and+ cycle =
    Arg.(
      value
      & flag
      & info
          [ "cycle" ]
          ~doc:
            "If the currently focused window matches the search, focus the next matching \
             window, if any")
  and+ warp = Ctl_cli.warp_flag in
  Command.Window (Focus_match { wmatch; cycle; warp })
;;

let name = "match"
let doc = "Focus a window matching the search pattern"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
