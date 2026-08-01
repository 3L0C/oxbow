open! Ocdwm_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ width = Arg.(required & pos 0 (some int32) None & info [] ~docv:"WIDTH") in
  Command.Border (Width width)
;;

let name = "width"
let doc = "Configure the border width"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
