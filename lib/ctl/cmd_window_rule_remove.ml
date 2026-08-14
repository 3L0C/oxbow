open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ indices =
    Ctl_cli.index_args
      ~doc:
        "The window rule(s) by index. See existing rules and their index with $(b,oxctl \
         window rules list)."
  in
  Command.Window (Rule_remove indices)
;;

let name = "remove"
let doc = "Remove a window rule"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
