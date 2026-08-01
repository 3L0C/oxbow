open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ delta = Ctl_cli.int_delta
  and+ scope = Ctl_cli.setting_scope_term in
  Command.Gaps (Inner { delta; scope })
;;

let name = "inner"
let doc = "Set the size of the inner gaps"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
