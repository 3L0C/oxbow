open! Oxbow_core
open! Oxbow_ipc

let command_term align =
  let open Cmdliner.Term.Syntax in
  let+ scope = Ctl_cli.setting_scope_term in
  Command.Layout (Scrolling (Align { align; scope }))
;;

let scroll_targets = Ctl_cli.enum_of Align.to_string Align.all

let mk_leaf (name, policy) =
  Ctl_cli.cmd_pair
    ~name
    ~doc:(Printf.sprintf "Set the scrolling layout alignment to %s" name)
  @@ command_term policy
;;

let name = "align"
let doc = "Set the scrolling layout alignment"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc @@ List.map mk_leaf scroll_targets
