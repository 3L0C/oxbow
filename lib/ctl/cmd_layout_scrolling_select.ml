open! Oxbow_core
open! Oxbow_ipc

let command_term policy =
  let open Cmdliner.Term.Syntax in
  let+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Scrolling (Select { policy; scope }))
;;

let scroll_targets = Ctl_cli.enum_of Scroll_policy.to_string Scroll_policy.all

let mk_leaf (name, policy) =
  Ctl_cli.cmd_pair
    ~name
    ~doc:(Printf.sprintf "Switch the scrolling layout with %s policy" name)
  @@ command_term policy
;;

let cmds, bind_cmds = List.map mk_leaf scroll_targets |> List.split
