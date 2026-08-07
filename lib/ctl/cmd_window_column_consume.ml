open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.target_one_window_term in
  Command.Window { cmd = Column_consume; target }
;;

let name = "consume"
let doc = "Merge the next column into the target column"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
