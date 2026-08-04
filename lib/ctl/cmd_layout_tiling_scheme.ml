open! Oxbow_core
open! Oxbow_ipc

let command_term scheme =
  let open Cmdliner.Term.Syntax in
  let+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Tiling (Scheme { scheme; scope }))
;;

let mk_leaf (s : Scheme.t) =
  let name = Scheme.to_string s in
  Ctl_cli.cmd_pair ~name ~doc:(Printf.sprintf "Switch to the %s tiling scheme" name)
  @@ command_term s
;;

let cmds, bind_cmds = List.map mk_leaf Scheme.all |> List.split
