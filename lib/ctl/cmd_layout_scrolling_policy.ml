open! Ocdwm_core
open! Ocdwm_ipc

let command_term policy =
  let open Cmdliner.Term.Syntax in
  let+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Scrolling (Policy { policy; scope }))
;;

let scroll_targets = Ctl_cli.enum_of Scroll_policy.to_string [ Visible; Left; Centered ]

let mk_leaf (name, policy) =
  Ctl_cli.cmd_pair
    ~name
    ~doc:(Printf.sprintf "Set the scrolling layout policy to %s" name)
  @@ command_term policy
;;

let name = "policy"
let doc = "Set the scrolling layout policy"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc @@ List.map mk_leaf scroll_targets
