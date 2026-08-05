open! Oxbow_core
open! Oxbow_ipc

let command_term scheme =
  let open Cmdliner.Term.Syntax in
  let+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Tiling (Scheme { scheme; scope }))
;;

let tiling_targets = Ctl_cli.enum_of Scheme.to_string Scheme.all

let mk_leaf (name, scheme) =
  Ctl_cli.cmd_pair ~name ~doc:(Printf.sprintf "Set the tiling layout scheme to %s" name)
  @@ command_term scheme
;;

let name = "scheme"
let doc = "Set the tiling layout scheme"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc @@ List.map mk_leaf tiling_targets
