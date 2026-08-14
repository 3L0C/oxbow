open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ indices =
    Ctl_cli.index_args
      ~doc:
        "The input rule(s) by index. See existing rules and their index with $(b,oxctl \
         input rules list)."
  in
  Command.Input (Rule_remove indices)
;;

let name = "remove"
let doc = "Remove an input rule"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
