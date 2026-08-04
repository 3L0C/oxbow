open! Oxbow_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ delta = Ctl_cli.int_delta
  and+ scope = Ctl_cli.setting_scope_term in
  Command.Gaps (Overview { delta; scope })
;;

let name = "overview"

let doc =
  "Set the size of the gaps for overview mode. A new output does not keep the $(b,--all) \
   value."
;;

let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
