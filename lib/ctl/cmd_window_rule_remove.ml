open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ index = Ctl_cli.index_arg in
  (* NOTE the target is not used *)
  Command.Window { cmd = Rule_remove index; target = Focused }
;;

let name = "remove"
let doc = "Remove a window rule"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
