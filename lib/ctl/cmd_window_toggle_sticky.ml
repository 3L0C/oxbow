open! Oxbow_core
open! Oxbow_ipc

let command_term toggle = Cmdliner.Term.const @@ Command.Window (Toggle_sticky toggle)
let toggle_targets = Ctl_cli.enum_of Sticky.Toggle.to_string Sticky.Toggle.all

let mk_leaf (name, scope) =
  Ctl_cli.cmd_pair
    ~name
    ~doc:(Printf.sprintf "Toggle the focused window sticky scope between off and %s" name)
  @@ command_term scope
;;

let name = "sticky"
let doc = "Toggle the window sticky state"
let cmd, bind_cmd = Ctl_cli.group_pair ~name ~doc (List.map mk_leaf toggle_targets)
