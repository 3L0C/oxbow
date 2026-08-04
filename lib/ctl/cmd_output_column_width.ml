open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ delta = Ctl_cli.float_delta in
  Command.Output (Column_width delta)
;;

let name = "width"
let doc = "Adjust all columns by $(i,DELTA) width"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
