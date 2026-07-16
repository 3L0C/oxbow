open! Ocdwm_core
open! Ocdwm_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ width = Arg.(required & pos 0 (some int32) None & info [] ~docv:"WIDTH") in
  Command.Set (Border_width width)
;;

let name = "width"
let doc = "Configure the border width"
let build mk_term = Ctl_cli.cmd ~name ~doc @@ mk_term command_term
let cmd = build Ctl_cli.command_term
let bind_cmd = build Ctl_cli.bind_term
