open! Ocdwm_ipc

let command_term =
  let open Cmdliner.Term.Syntax in
  let+ delta = Ctl_cli.float_delta
  and+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Tiling (Mfact { delta; scope }))
;;

let name = "mfact"
let doc = "Set the ratio for the master stack"
let cmd, bind_cmd = Ctl_cli.cmd_pair ~name ~doc command_term
