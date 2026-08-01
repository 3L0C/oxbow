open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ delta = Ctl_cli.int_delta
  and+ scope = Ctl_cli.setting_scope_term in
  Command.Gaps (Outer { delta; scope })
;;

let name = "outer"
let doc = "Set the size of the outer gaps"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
