open! Oxbow_ipc

let command_term =
  let open Cmdliner in
  let open Cmdliner.Term.Syntax in
  let+ name =
    Arg.(
      value
      & pos 0 string "scratch"
      & info [] ~doc:"The name of the scratchpad group to toggle." ~docv:"NAME")
  in
  Command.Scratchpad (Toggle name)
;;

let name = "toggle"
let doc = "Toggle the scratchpad group NAME"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
