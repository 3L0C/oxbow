open! Oxbow_core
open! Oxbow_ipc

let command_term scope =
  let open Cmdliner.Term.Syntax in
  let+ target = Ctl_cli.target_any_window_term in
  Command.Window { cmd = Set_sticky scope; target }
;;

let scope_targets = Ctl_cli.enum_of Sticky.to_string Sticky.all

let mk_leaf (name, policy) =
  Ctl_cli.cmd_pair
    ~name
    ~doc:(Printf.sprintf "Set the focused window sticky scope to %s" name)
  @@ command_term policy
;;

let cmds, bind_cmds = List.map mk_leaf scope_targets |> List.split
