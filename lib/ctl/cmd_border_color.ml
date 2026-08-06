open! Oxbow_core
open! Oxbow_ipc

let command_term which =
  let open Cmdliner.Term.Syntax in
  let+ color = Ctl_cli.color_arg in
  Command.Border (Color { which; color })
;;

let border_targets = Ctl_cli.enum_of Border_target.to_string Border_target.all

let mk_leaf (name, which) =
  Ctl_cli.cmd_pair
    ~name
    ~doc:(Printf.sprintf "Set the border color when the window state is %s" name)
  @@ command_term which
;;

let name = "color"
let doc = "Set the window color for a given state"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc @@ List.map mk_leaf border_targets
